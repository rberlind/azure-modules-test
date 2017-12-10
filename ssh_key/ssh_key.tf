variable "public_key" {
  description = "contents of SSH public key that will be uploaded to linux VM as id_rsa.pub"
}

resource "null_resource" "write_public_key" {
  provisioner "local-exec" {
    command = "echo '${var.public_key}' > id_rsa.pub"
  }
  provisioner "local-exec" {
    command = "chmod 400 id_rsa.pub"
  }
}

output "ssh_key_file_name" {
  value = "id_rsa.pub"
}
