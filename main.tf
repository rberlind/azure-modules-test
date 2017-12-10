terraform {
  required_version = ">= 0.11.0"
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
  default = "pTFE123!"
}

variable "public_key" {
  description = "contents of SSH public key that will be uploaded to linux VM as id_rsa.pub"
}

module "ssh_key" {
  source = "./ssh_key"
  public_key = "${var.public_key}"
}

module "linuxserver" {
  source              = "Azure/compute/azurerm"
  location            = "${var.location}"
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["${var.linux_dns_prefix}"]
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
  ssh_key = "${module.ssh_key.ssh_key_file_name}"
}

module "windowsserver" {
  source              = "Azure/compute/azurerm"
  location            = "${var.location}"
  vm_hostname         = "pwc-ptfe"
  admin_password      = "${var.admin_password}"
  vm_os_simple        = "WindowsServer"
  public_ip_dns       = ["${var.windows_dns_prefix}"]
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"
}

module "network" {
  source              = "Azure/network/azurerm"
  location            = "${var.location}"
  resource_group_name = "terraform-compute"
  allow_ssh_traffic   = true
}

# Sleep before outputting public names of VMs
resource "null_resource" "sleep" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  depends_on = ["module.linuxserver", "module.windowsserver"]
}

data "null_data_source" "dns_names" {
  inputs = {
    linux_dns_names = "${join(",", module.linuxserver.public_ip_dns_name)}"
    windows_dns_names = "${join(",", module.windowsserver.public_ip_dns_name)}"
  }
  depends_on = ["null_resource.sleep"]
}

output "linux_vm_public_name" {
  value = "${data.null_data_source.dns_names.outputs["linux_dns_names"]}"
}

output "windows_vm_public_name" {
  value = "${data.null_data_source.dns_names.outputs["windows_dns_names"]}"
}
