# # Firewall
# resource "linode_firewall" "zzub" {
#   label = "zzub"
#   tags  = []

#   # Block by default
#   # inbound_policy  = "DROP"
#   # outbound_policy = "DROP"

#   # TODO: Enable firewall again
#   inbound_policy  = "ACCEPT"
#   outbound_policy = "ACCEPT"

# #   # Allow HTTP connections
# #   inbound {
# #     label    = "http_inbound"
# #     action   = "ACCEPT"
# #     protocol = "TCP"
# #     ports    = "80, 443"
# #     ipv4     = ["0.0.0.0/0"]

# #   }

# #   outbound {
# #     label    = "http_outbound"
# #     action   = "ACCEPT"
# #     protocol = "TCP"
# #     ports    = "80, 443"
# #     ipv4     = ["0.0.0.0/0"]

# #   }

# #   # Allow inbound DNS connections
# #   inbound {
# #     label    = "dns_inbound"
# #     action   = "ACCEPT"
# #     protocol = "UDP"
# #     ports    = "53"
# #     ipv4     = ["0.0.0.0/0"]

# #   }

# #   # Allow SSH connections
# #   inbound {
# #     label    = "ssh_inbound"
# #     action   = "ACCEPT"
# #     protocol = "TCP"
# #     ports    = "22"
# #     ipv4     = ["0.0.0.0/0"]

# #   }

# #   outbound {
# #     label    = "ssh_outbound"
# #     action   = "ACCEPT"
# #     protocol = "TCP"
# #     ports    = "22"
# #     ipv4     = ["0.0.0.0/0"]

# #   }

# #   # Allow traffic for Minecraft server
# #   inbound {
# #     label    = "minecraft_inbound"
# #     action   = "ACCEPT"
# #     protocol = "TCP"
# #     ports    = "25565"
# #     ipv4     = ["0.0.0.0/0"]

# #   }

# #   outbound {
# #     label    = "minecraft_outbound"
# #     action   = "ACCEPT"
# #     protocol = "TCP"
# #     ports    = "25565"
# #     ipv4     = ["0.0.0.0/0"]
# #   }

#   linodes = [linode_instance.zzub.id]
# }
