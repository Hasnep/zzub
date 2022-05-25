# Authentication
variable "linode_token" {
  type      = string
  sensitive = true
}

variable "public_ssh_keys" {
  type      = list(string)
  sensitive = true
}

variable "root_password" {
  type      = string
  sensitive = true
}

# Compute
variable "region" {
  default = "eu-west"
  type    = string
}

variable "compute_type" {
  default = "g6-nanode-1"
  type    = string
}

variable "compute_image" {
  type    = string
}
