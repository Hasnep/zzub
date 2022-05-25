resource "linode_instance" "zzub" {
  label            = "zzub"
  region           = var.region
  type             = var.compute_type
  image            = var.compute_image
  authorized_keys  = var.public_ssh_keys
  authorized_users = []
  backups_enabled  = false
  private_ip       = false
  root_pass        = var.root_password
  tags             = []

}

output "server_ip" {
  description = "The server's public IP address"
  value       = linode_instance.zzub.ip_address
}
