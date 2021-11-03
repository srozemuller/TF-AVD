# In this file all variable values are stored.
# Initial Image settings
init_vm_name = "vm-init"
init_rg_name = "rg-temp-init"

# Virtual Network settings
vnet_name = "vnet-uk-demo"
vnet_address_space = ["10.0.0.0/16"]
vnet_subnet_name = "DefaultSubnet"
vnet_subnet_address = ["10.0.1.0/24"]
vnet_nsg_name = "nsg-vnet-uk-demo"

# Diagnosics settings
laws_name-prefix = "laws-avd"
avd_diagnostics_name = "AVD - Diagnostics"

# Shared Image Gallery settings
sig_name = "UKDemo"
sig_def_name = "AVDRocks"
sig_def_type = "Windows"
sig_def_generation = "V2"
sig_def_publisher = "The"
sig_def_offer = "UK"
sig_def_sku = "AVDUG"

# Azure Virtual Desktop settings
avd_rg_name = "rg-uk-demo"
avd_rg_location = "West Europe"

## Hostpool
avd_hostpool_name = "UK-Demo"
avd_hostpool_friendly_name = "UK AVD UserGroup"
avd_hostpool_description = "This is a rockstar demo"
avd_hostpool_type = "Personal"

## Application Group
avd_applicationgroup_name = "UK-Desktop"
avd_applicationgroup_friendly_name = "UK-Applications"
avd_applicationgroup_description = "A nice group of applications"
avd_applicationgroup_type = "Desktop"

## Workpace
avd_workspace_name = "UK-Workspace"
avd_workspace_friendly_name = "UKAVDUG-Workspace"
avd_workspace_description = "Work from home"

## Assign to group
aad_group_name = "All Users"

## Sessionhosts AzureAD
avd_sessionhost_count = 2
avd_sessionhost_prefix = "avd"