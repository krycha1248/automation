variable "nazwa_instancji" {
  type        = list(string)
  description = "Nazwy instancji"
  default = [
    "Wlodek-Meet"
  ]
}

variable "subdomena" {
  type        = string
  description = "Subdomena"
  default     = "meet"
}

resource "openstack_compute_instance_v2" "meet" {
  count       = length(var.nazwa_instancji)
  name        = var.nazwa_instancji[count.index]
  provider    = openstack.ovh
  image_name  = "Debian 11"
  flavor_name = "d2-2"
#  flavor_name = "d2-8"
  key_pair    = "ssh"
  network {
    name = "Ext-Net"
  }
}

resource "cloudflare_record" "nowy" {
  zone_id = var.cf_wlodek_pro_zone_id
  count   = length(openstack_compute_instance_v2.meet)
  name    = length(openstack_compute_instance_v2.meet) == 1 ? "${var.subdomena}" : "${var.subdomena}${count.index + 1}"
  type    = "A"
  value   = openstack_compute_instance_v2.meet[count.index].network[0].fixed_ip_v4
  ttl     = "1"
}

resource "local_file" "variable" {
  count    = length(var.nazwa_instancji)
  filename = "../../ansible/host_vars/${openstack_compute_instance_v2.meet[count.index].network[0].fixed_ip_v4}.yml"
  content  = <<-UN
    ---
    ansible_ssh_user: ${lower(regex("[A-z]+", openstack_compute_instance_v2.meet[count.index].image_name))}
    domain_name: ${cloudflare_record.nowy[count.index].name}.wlodek.pro
    ...
    UN
}

resource "cloudflare_record" "nowy2" {
  zone_id = var.cf_wlodek_pro_zone_id
  count   = length(openstack_compute_instance_v2.meet)
  name    = length(openstack_compute_instance_v2.meet) == 1 ? "www.${var.subdomena}" : "www.${var.subdomena}${count.index + 1}"
  type    = "CNAME"
  value   = length(openstack_compute_instance_v2.meet) == 1 ? "${var.subdomena}.wlodek.pro" : "${var.subdomena}${count.index + 1}.pro"
  ttl     = "1"
}

resource "local_file" "inventory" {
  filename = "dyn-inventory"
  content  = <<-DYN
    [wdrozenie]
    %{for ip in openstack_compute_instance_v2.meet[*].network[0].fixed_ip_v4~}
    ${ip}
    %{endfor~}
    DYN
  provisioner "local-exec" {
    command = "sleep 10; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -T 600 -i dyn-inventory --private-key=~/ssh_key ../../ansible/meet.yml --ask-vault-pass -u root -e 'variable_host=all'"
  }
}