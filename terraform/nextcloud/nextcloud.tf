variable "subdomena" {
  type        = list(string)
  description = "Subdomena"
  default = [
    "nextcloud",
    "wordpress"
  ]
}

resource "openstack_compute_instance_v2" "ws" {
  name        = "Włodek Services"
  provider    = openstack.ovh
  image_name  = "Debian 11"
  flavor_name = "d2-2"
  #    flavor_name = "d2-8"
  key_pair = "ssh"
  network {
    name = "Ext-Net"
  }
}

resource "cloudflare_record" "nowy" {
  zone_id = var.cf_wlodek_pro_zone_id
  count   = length(var.subdomena)
  name    = var.subdomena[count.index]
  type    = "A"
  value   = openstack_compute_instance_v2.ws.network[0].fixed_ip_v4
  ttl     = "1"
}

resource "local_file" "variables" {
  filename = "../../ansible/host_vars/${openstack_compute_instance_v2.ws.network[0].fixed_ip_v4}.yml"
  content  = <<-UN
              ---
              ansible_ssh_user: ${lower(regex("[A-z]+", openstack_compute_instance_v2.ws.image_name))}
              domain_name:
              %{for dn in var.subdomena}${"  "}${~dn}: ${dn}.wlodek.pro
              %{endfor~}...
              UN
}

resource "cloudflare_record" "nowy2" {
  zone_id = var.cf_wlodek_pro_zone_id
  count   = length(var.subdomena)
  name    = "www.${var.subdomena[count.index]}"
  type    = "CNAME"
  value   = "${var.subdomena[count.index]}.wlodek.pro"
  ttl     = "1"
}

resource "local_file" "inventory" {
  filename = "dyn-inventory"
  content  = <<-DYN
              [wdrozenie]
              %{for ip in openstack_compute_instance_v2.ws[*].network[0].fixed_ip_v4~}${ip}
              %{endfor~}
              DYN
  provisioner "local-exec" {
    command = "sleep 10; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -T 600 -i dyn-inventory --private-key=~/ssh_key ../../ansible/nextcloud.yml --ask-vault-pass -u root -e 'variable_host=all'"
  }
}