terraform {
  required_version = ">= 0.11.7"
}

variable "location" {
  description = "Azure location in which to create resources"
  default = "East US"
}

variable "windows_dns_prefix" {
  description = "DNS prefix to add to to public IP address for Windows VM"
}

variable "admin_password" {
  description = "admin password for Windows VM"
  default = "pTFE1234!"
}

variable "vm_size" {
  description = "size of the Azure VM"
  default = "Standard_A1"
}

variable "storage_account_type" {
  description = "Defines the type of storage account: Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS"
  default = "Standard_LRS"
}

provider "azurerm" {}

module "windowsserver" {
  source              = "Azure/compute/azurerm"
  version             = "1.2.0"
  location            = "${var.location}"
  resource_group_name = "${var.windows_dns_prefix}-rc"
  vm_hostname         = "demohost"
  admin_password      = "${var.admin_password}"
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["${var.windows_dns_prefix}"]
  storage_account_type = "${var.storage_account_type}"
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
  vm_size             = "${var.vm_size}"
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "2.0.0"
  location            = "${var.location}"
  resource_group_name = "${var.windows_dns_prefix}-rc"
  allow_ssh_traffic   = true
}

output "windows_vm_public_name"{
  value = "${module.windowsserver.public_ip_dns_name}"
}
