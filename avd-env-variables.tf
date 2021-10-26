variable "avd_rg_name" {
  type        = string
  description = "This is the AVD resource group"
}

variable "avd_rg_location" {
  type        = string
  description = "This is the AVD resource groups location"
}


variable "init_rg_name" {
  type        = string
  description = "This is resource group where the initial VM for image creation lives"
}

variable "init_vm_name" {
    type        = string
    description = "How is the initial VM for image creation called"
}

variable "vnet_name" {
  type        = string
  description = "What is the VNETs name"
}
variable "vnet_address_space" {
  type        = list
  description = "What is the VNETs addresspace"
}

variable "vnet_subnet_name" {
  type        = string
  description = "What is the AVD subnet"
}

variable "vnet_subnet_address" {
  type        = list
  description = "What is the subnet addresspace"
}


variable "vnet_nsg_name" {
  type        = string
  description = "Network security group name"
}

variable "laws_name-prefix" {
  type        = string
  description = "Enter the Loganalyics workspace name prefix"
}
variable "avd_diagnostics_name" {
  type        = string
  description = "How is the diagnosics settings in AVD called"
}


variable "sig_name" {
  type        = string
  description = "What is the Shared Image Galler name"
}

variable "sig_def_name" {
  type        = string
  description = "How is the definition called"
}

variable "sig_def_type" {
  type        = string
  description = "What is the definitions type"
}

variable "sig_def_generation" {
  type        = string
  description = "What is the HyperV generation, must be the same as the initial image."
}
variable "sig_def_publisher" {
  type        = string
  description = "What is the image publisher"
}

variable "sig_def_offer" {
  type        = string
  description = "What is the image offer"
}

variable "sig_def_sku" {
  type        = string
  description = "What is the image SKU"
}

variable "avd_hostpool_name" {
  type        = string
  description = "What is de AVD hostpools name"
}
variable "avd_hostpool_friendly_name" {
  type        = string
  description = "What is de AVD hostpools friendly name"
}

variable "avd_hostpool_description" {
  type        = string
  description = "What is the AVD hostpools description"
}

variable "avd_hostpool_type" {
  type        = string
  description = "What is the AVD hostpools type"
}

variable "avd_applicationgroup_name" {
  type        = string
  description = "What is the AVD application group name"
}

variable "avd_applicationgroup_friendly_name" {
  type        = string
  description = "What is the AVD application group friendly name"
}

variable "avd_applicationgroup_description" {
  type        = string
  description = "What is the AVD application group description"
}

variable "avd_applicationgroup_type" {
  type        = string
  description = "What is the AVD application group type"
}

variable "avd_workspace_name" {
  type        = string
  description = "What is the AVD workspace name"
}
variable "avd_workspace_friendly_name" {
  type        = string
  description = "What is the AVD workspace friendly name"
}
variable "avd_workspace_description" {
  type        = string
  description = "What is the AVD description"
}

variable "avd_sessionhost_count" {
  type        = number
  description = "Number of session host to deploy at first time"
}

variable "avd_sessionhost_prefix" {
  type        = string
  description = "The sessionhosts prefix"
}