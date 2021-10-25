terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
    
  }
}

provider "azurerm" {
  features {}
}
resource "random_integer" "random" {
  min = 1
  max = 50000
}
# Get resources by type, create spoke vNet peerings
data "azurerm_resources" "initVM" {
  type = "Microsoft.Compute/virtualMachines"
  name = var.init_vm_name
  resource_group_name = var.init_rg_name
}

output "intiVm" {
  value = data.azurerm_resources.initVM.id
}
resource "random_string" "string" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

resource "azurerm_resource_group" "rg-avd" {
  name     = var.avd_rg_name
  location = var.avd_rg_location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg-avd.location
  resource_group_name = azurerm_resource_group.rg-avd.name
  address_space       = var.vnet_address_space
  tags = {
    environment = "Terraform test"
  }
}

resource "azurerm_subnet" "defaultSubnet" {
  name           = "defaultSubnet"
  resource_group_name = azurerm_resource_group.rg-avd.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.vnet_nsg_name
  location            = azurerm_resource_group.rg-avd.location
  resource_group_name = azurerm_resource_group.rg-avd.name
  security_rule {
    name                       = "allow-rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 3389
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.defaultSubnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
resource "azurerm_log_analytics_workspace" "laws" {
  name                = "${var.laws_name-prefix}-${random_integer.random.result}"
  location            = azurerm_resource_group.rg-avd.location
  resource_group_name = azurerm_resource_group.rg-avd.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_shared_image_gallery" "sig" {
  name                = var.sig_name
  resource_group_name = azurerm_resource_group.rg-avd.name
  location            = azurerm_resource_group.rg-avd.location
  description         = "Shared images and things."
}


resource "azurerm_shared_image" "sig_def" {
  name                = var.sig_def_name
  gallery_name        = azurerm_shared_image_gallery.sig.name
  resource_group_name = azurerm_resource_group.rg-avd.name
  location            = azurerm_resource_group.rg-avd.location
  os_type             = var.sig_def_type
  hyper_v_generation = var.sig_def_generation
  identifier {
    publisher = var.sig_def_publisher
    offer     = var.sig_def_offer
    sku       = var.sig_def_sku
  }
}
resource "azurerm_shared_image_version" "sig_version" {
  name                = formatdate("YYYY.MM.DD", timestamp())
  gallery_name        = azurerm_shared_image_gallery.sig.name
  image_name          = azurerm_shared_image.sig_def.name
  resource_group_name = azurerm_shared_image.sig_def.resource_group_name
  location            = azurerm_shared_image.sig_def.location
  managed_image_id    = data.azurerm_resources.initVM.id
  
  target_region {
    name                   = azurerm_shared_image_gallery.sig.location
    regional_replica_count = 5
    storage_account_type   = "Standard_LRS"
  }
}

resource "azurerm_virtual_desktop_host_pool" "avd-hp" {
  location            = azurerm_resource_group.rg-avd.location
  resource_group_name = azurerm_resource_group.rg-avd.name

  name                     = var.avd_hostpool_name
  friendly_name            = var.avd_hostpool_friendly_name
  validate_environment     = true
  start_vm_on_connect      = true
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;targetisaadjoined:i:1;"
  description              = var.avd_hostpool_description
  type                     = var.avd_hostpool_type
  maximum_sessions_allowed = 1
  load_balancer_type       = "Persistent"
  personal_desktop_assignment_type = "Automatic"
  registration_info {
    expiration_date = timeadd(timestamp(), "24h")
  }
}

resource "azurerm_virtual_desktop_application_group" "desktopapp" {
  name                = var.avd_applicationgroup_name
  location            = azurerm_resource_group.rg-avd.location
  resource_group_name = azurerm_resource_group.rg-avd.name
  type          = var.avd_applicationgroup_type
  host_pool_id  = azurerm_virtual_desktop_host_pool.avd-hp.id
  friendly_name = var.avd_applicationgroup_friendly_name
  description   = var.avd_applicationgroup_description
}

resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = var.avd_workspace_name
  location            = azurerm_resource_group.rg-avd.location
  resource_group_name = azurerm_resource_group.rg-avd.name
  friendly_name = var.avd_workspace_friendly_name
  description   = var.avd_workspace_description
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workspaceremoteapp" {
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.desktopapp.id
}


resource "azurerm_network_interface" "sessionhost_nic" {
  count = var.avd_sessionhost_count

  name                = "nic-${var.avd_sessionhost_prefix}-${count.index}"
  location            = azurerm_resource_group.rg-avd.location
  resource_group_name = azurerm_resource_group.rg-avd.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.defaultSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "avd_sessionhost" {
  depends_on = [
      azurerm_network_interface.sessionhost_nic
  ]
  
  count = var.avd_sessionhost_count

  name                = "${var.avd_sessionhost_prefix}-${count.index}"
  resource_group_name = azurerm_resource_group.rg-avd.name
  location            = azurerm_resource_group.rg-avd.location
  size                = "Standard_B2MS"
  admin_username      = "adminuser"
  admin_password      = random_string.string.result
  
  network_interface_ids = [
    "${azurerm_resource_group.rg-avd.id}/providers/Microsoft.Network/networkInterfaces/nic-${var.avd_sessionhost_prefix}-${count.index}"
  ]

  identity {
    type  = "SystemAssigned"
  }
  
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_id = azurerm_shared_image_version.sig_version.id

  tags = {
    environment = "Production"
    hostpool = var.avd_workspace_name
  }
}

resource "azurerm_monitor_diagnostic_setting" "avd-hostpool" {
  name               = "AVD - Diagnostics"
  target_resource_id = azurerm_virtual_desktop_host_pool.avd-hp.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.laws.id

  log {
    category = "Error"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
  count = var.avd_sessionhost_count
  depends_on = [
      azurerm_windows_virtual_machine.avd_sessionhost
  ]

  name                 = "AADLoginForWindows"
  virtual_machine_id   = "${azurerm_resource_group.rg-avd.id}/providers/Microsoft.Compute/virtualMachines/${var.avd_sessionhost_prefix}-${count.index}"
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"

}