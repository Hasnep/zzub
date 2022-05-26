resource "linode_firewall" "zzub" {
  label   = "zzub"
  linodes = [linode_instance.zzub.id]
  tags    = []

  # TODO: Enable firewall
  inbound_policy  = "ACCEPT"
  outbound_policy = "ACCEPT"

  # # Block by default
  # inbound_policy  = "DROP"
  # outbound_policy = "DROP"

  # Allow HTTP connections
  outbound {
    label    = "http_inbound"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80, 443"
    ipv4     = ["0.0.0.0/0"]
  }

  # Allow inbound DNS connections
  inbound {
    label    = "dns_inbound"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "53"
    ipv4     = ["0.0.0.0/0"]
  }

  # Allow SSH connections
  inbound {
    label    = "ssh_inbound"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
  }

  outbound {
    label    = "ssh_outbound"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"]
  }

  # Allow Websocket connections
  inbound {
    label    = "websocket_inbound"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "5001"
    ipv4     = ["0.0.0.0/0"]
  }

  outbound {
    label    = "websocket_outbound"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "5001"
    ipv4     = ["0.0.0.0/0"]
  }
}
