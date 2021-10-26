# In this file all variable values are stored.
# Initial Image settings
init_vm_name = "vm-init"
init_rg_name = "rg-temp-init"

# Virtual Network settings
vnet_name = "vnet-roz-bh-001"
vnet_address_space = ["10.0.0.0/16"]
vnet_subnet_name = "DefaultSubnet"
vnet_subnet_address = ["10.0.1.0/24"]
vnet_nsg_name = "nsg-roz-bh-001"

# Diagnosics settings
laws_name-prefix = "laws-avd"
avd_diagnostics_name = "AVD - Diagnostics"

# Shared Image Gallery settings
sig_name = "Dutch_Gallery"
sig_def_name = "Bloody-Harry"
sig_def_type = "Windows"
sig_def_generation = "V2"
sig_def_publisher = "Dutch"
sig_def_offer = "Bloody"
sig_def_sku = "Harry"

# Azure Virtual Desktop settings
avd_rg_name = "rg-roz-bloody-harry"
avd_rg_location = "West Europe"

## Hostpool
avd_hostpool_name = "Dutch-Harry"
avd_hostpool_friendly_name = "The Dutch Bloody Harry"
avd_hostpool_description = "An pumpking cocktail with some Dutch aroma's"
avd_hostpool_type = "Personal"

## Application Group
avd_applicationgroup_name = "Bloody-Desktop"
avd_applicationgroup_friendly_name = "Bloody-Applications"
avd_applicationgroup_description = "A nice group of applications"
avd_applicationgroup_type = "Desktop"

## Workpace
avd_workspace_name = "Dutch-Workspace"
avd_workspace_friendly_name = "Dutch-Workspace"
avd_workspace_description = "Work from home"

## Assign to group
aad_group_name = "All Users"

## Sessionhosts AzureAD
avd_sessionhost_count = 2
avd_sessionhost_prefix = "avd"