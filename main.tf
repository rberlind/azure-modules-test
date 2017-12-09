terraform {
  required_version = ">= 0.11.0"
}

variable "location" {
  description = "Azure location in which to create the resources"
  default = "East US"
}

variable "linux_dns_prefix" {
  description = "DNS prefix to add to to public IP address for Linux VM"
  default = "pwc-ptfe-linux"
}

variable "windows_dns_prefix" {
  description = "DNS prefix to add to to public IP address for Windows VM"
  default = "pwc-ptfe-windows"
}

variable "admin_password" {
  description = "admin password for Windows VM"
  default = "pTFE123!"
}

variable "public_key" {
  description "contents of SSH public key that will be uploaded to linux VM"
}

resource "null_resource" "public_key" {
  provisioner "local-exec" {
    command = "echo '${var.public_key}' > public_key.pem"
  }
  provisioner "local-exec" {
    command = "chmod 600 public_key.pem"
  }
}

module "linuxserver" {
  source              = "Azure/compute/azurerm"
  location            = "${var.location}"
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["${var.linux_dns_prefix}"]
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
}

module "windowsserver" {
  source              = "Azure/compute/azurerm"
  location            = "${var.location}"
  vm_hostname         = "pwc-ptfe" // line can be removed if only one VM module per resource group
  admin_password      = "${var.admin_password}"
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["${var.windows_dns_prefix}"]
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
}

module "network" {
  source              = "Azure/network/azurerm"
  location            = "${var.location}"
  resource_group_name = "terraform-compute"
}

output "linux_vm_public_name"{
  value = "${module.linuxserver.public_ip_dns_name}"
}

output "windows_vm_public_name"{
  value = "${module.windowsserver.public_ip_dns_name}"
}
