provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_ssh_keys" "developer_keys_by_selector" {
  with_selector = "gameserver_admin"
}

resource "hcloud_server" "objpatrish_terraria" {
  name        = var.server_name
  image       = var.server_image
  server_type = var.server_type
  location    = var.location
  keep_disk   = "false"
  ssh_keys    = data.hcloud_ssh_keys.developer_keys_by_selector.*.id
  labels      = { "environment" = "gameserver" }
}

# custom provider from https://github.com/adamdecaf/terraform-provider-namecheap
provider "namecheap" {
  username    = var.namecheap_user
  api_user    = var.namecheap_user
  token       = var.namecheap_token
  ip          = var.namecheap_user_pubip
  use_sandbox = false
}

# Create a DNS A Record for a domain you own
resource "namecheap_record" "objpatrish_terraria_dns" {
  name    = var.namecheap_domain_record
  domain  = var.namecheap_domain
  address = hcloud_server.objpatrish_terraria.ipv4_address
  mx_pref = 10
  ttl     = 300
  type    = "A"
}

resource "namecheap_record" "objpatrish_terraria_dns_wildcard" {
  depends_on = [namecheap_record.objpatrish_terraria_dns]
  name       = "*.${var.namecheap_domain_record}"
  domain     = var.namecheap_domain
  address    = "${var.namecheap_domain_record}.${var.namecheap_domain}"
  mx_pref    = 10
  ttl        = 300
  type       = "CNAME"
}
