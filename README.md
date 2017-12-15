# Example For Using the Azure Compute Module
This Terraform configuration provides an example for using the [Azure compute module](https://registry.terraform.io/modules/Azure/compute/azurerm/1.1.0) from the public Terraform Registry. It is configured for use with Terraform Enterprise (TFE).

## Introduction
This Terraform configuration will create an Azure resource group, virtual network (with subnets), security groups, and 2 VMs, one Linux (Ubuntu 16.04) and one Windows. It will also create disks, network interfaces, and Azure availability sets for the VMs.

## Instructions
You can use the original GitHub repository, rberlind/azure-modules-test or create a fork of it. You do not actually need to clone the repository (or any fork of it) to your local machine since the Terraform code will be running on the Terraform Enterprise server after TFE downloads the code from GitHub.

1. Create a workspace on your TFE Enterprise Server (which could be the SaaS TFE server running at https://atlas.hashicorp.com).
1. Point your workspace at this repository or a fork of it.
1. On the Variables tab of your workspace, add linux_dns_prefix and windows_dns_prefix Terraform variables and set them to strings which will be used as the initial segment of the DNS names for the Linux and Windows VMs that will be provisioned in Azure. These must be globally unique. Additionally, certain values might give warnings about trademarks being used.
1. On the Variables tab of your workspace, add the public_key Terraform variable and populate it with the contents of the public SSH key you want to upload to the Linux VM so that you can then use your private SSH key from the same key pair to ssh to the Linux VM.
1. Click the Save button to save your Terraform variables.
1. On the Variables tab of your workspace, add environment variables ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_SUBSCRIPTION_ID, and ARM_TENANT_ID and set them to the  credentials of an Azure service principal as described [here](https://www.terraform.io/docs/providers/azurerm/authenticating_via_service_principal.html).
1. Click the Save button to save your environment variables.
1. Click the "Queue Plan" button in the upper right corner of the workspace page.
1. After the Plan successfully completes, click the "Confirm and Apply" button at the bottom of the page.

Note that you will probably see 2 errors from inside the Azure compute module at the end of the apply indicating that the resource azurerm_public_ip.vm does not have an ip_address. This is because the public IP addresses are not ready when the module writes its outputs. But the VMs will be correctly provisioned. If you run apply a second time, you will not see any errors.

## Destroying
Do the following to destroy the Azure infrastructure provisioned by this configuration.

1. On the Variables tab of your workspace, add an environment variable, CONFIRM_DESTROY, with value 1.
1. On the Settings tab of your workspace, click the "Queue destroy plan" button.
1. After the plan for the destroy completes, click the "Confirm and Apply" button at the bottom of the page to destroy the Azure infrastructure.
