variable "avd_rg_name" {
  type        = string
  default     = "rg-roz-bloody-harry"
}

variable "avd_rg_location" {
  type        = string
  default     = "West Europe"
}


variable "init_rg_name" {
  type        = string
  default     = "rg-temp-init"
}

variable "init_vm_name" {
    type      = string
  default     = "vm-init"
  }

variable "vnet_name" {
  type        = string
  default     = "vnet-roz-bh-001"
}
variable "vnet_nsg_name" {
  type        = string
  default     = "nsg-roz-bh-001"
}

variable "vnet_address_space" {
  type        = list
  default     = ["10.0.0.0/16"]
}

variable "laws_name-prefix" {
  type        = string
  default     = "la-avd"
}
variable "sig_name" {
  type = string
  default = "Dutch_Gallery"
}

variable "sig_def_name" {
  type = string
  default = "Bloody-Harry"
}

variable "sig_def_type" {
  type = string
  default = "Windows"
}

variable "sig_def_generation" {
  type = string
  default = "V2"
}
variable "sig_def_publisher" {
  type = string
  default = "Rozemuller"
}

variable "sig_def_offer" {
  type = string
  default = "Bloody"
}

variable "sig_def_sku" {
  type = string
  default = "Harry"
}

variable "avd_hostpool_name" {
  type        = string
  default     = "Roz-Dutch"
}
variable "avd_hostpool_friendly_name" {
  type        = string
  default     = "The Dutch Bloody Harry"
}

variable "avd_hostpool_description" {
  type        = string
  default     = "An pumpking cocktail with some Dutch aroma's"
}

variable "avd_hostpool_type" {
  type        = string
  default     = "Personal"
}

variable "avd_applicationgroup_name" {
  type        = string
  default     = "Bloody-Apps"
}

variable "avd_applicationgroup_type" {
  type        = string
  default     = "Desktop"
}
variable "avd_applicationgroup_friendly_name" {
  type        = string
  default     = "Bloody-Applications"
}

variable "avd_applicationgroup_description" {
  type        = string
  default     = "Some bloody applications"
}

variable "avd_workspace_name" {
  type        = string
  default     = "Dutch-Workspace"
}
variable "avd_workspace_friendly_name" {
  type        = string
  default     = "Dutch-Workspace"
}
variable "avd_workspace_description" {
  type        = string
  default     = "A Dutch workspace"
}

variable "avd_sessionhost_count" {
  type = number
  default = 2
  description = "Number of session host to deploy at first time"
}

variable "avd_sessionhost_prefix" {
  type = string
  default = "avd"
  description = "The sessionhosts prefix"
}