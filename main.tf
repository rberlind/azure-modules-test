terraform {
  required_version = ">= 0.10.8"
}

variable "location" {
  description = "Azure location in which to create resources"
  default = "East US"
}

variable "linux_dns_prefix" {
  description = "DNS prefix to add to to public IP address for Linux VM"
}

variable "windows_dns_prefix" {
  description = "DNS prefix to add to to public IP address for Windows VM"
}

variable "admin_password" {
  description = "admin password for Windows VM"
  default = "pTFE1234!"
}

variable "public_key" {
  description = "contents of SSH public key that will be uploaded to linux VM as id_rsa.pub"
}

resource "local_file" "ssh_key" {
  content = "${var.public_key}"
  filename = "id_rsa.pub"
}

module "linuxserver" {
  source              = "Azure/compute/azurerm"
  version             = "1.1.5"
  location            = "${var.location}"
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["${var.linux_dns_prefix}"]
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
  ssh_key = "${local_file.ssh_key.filename}"
}

module "windowsserver" {
  source              = "Azure/compute/azurerm"
  version             = "1.1.5"
  location            = "${var.location}"
  vm_hostname         = "pwc-ptfe"
  admin_password      = "${var.admin_password}"
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["${var.windows_dns_prefix}"]
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "1.1.1"
  location            = "${var.location}"
  resource_group_name = "terraform-compute"
  allow_ssh_traffic   = true
}

output "linux_vm_public_name"{
  value = "${module.linuxserver.public_ip_dns_name}"
}

output "windows_vm_public_name"{
  value = "${module.windowsserver.public_ip_dns_name}"
}
