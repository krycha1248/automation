variable "sub_domain" {
  description = "(sub)domena"
  type = string
  default = "ansible"
}

resource "openstack_compute_instance_v2" "instance" {
  name = "Deploy"
  provider = openstack.ovh
  image_name = "Debian 11"
  flavor_name = "d2-2"
  key_pair = "ssh"
  network {
    name = "Ext-Net"
  }
}

resource "cloudflare_record" "recordA" {
  zone_id = var.cf_wlodek_pro_zone_id
  name = var.sub_domain
  type = "A"
  value = openstack_compute_instance_v2.instance.network[0].fixed_ip_v4
  ttl = "1"
}

resource "cloudflare_record" "recordCNAME" {
  zone_id = var.cf_wlodek_pro_zone_id
  name = "www.${var.sub_domain}"
  type = "CNAME"
  value = cloudflare_record.recordA.hostname
  ttl = "1"
}

resource "local_file" "inventory" {
  filename = "dyn-inventory"
  content  = <<-DYN
    [wdrozenie]
    %{for ip in openstack_compute_instance_v2.instance[*].network[0].fixed_ip_v4~}
    ${ip} ansible_ssh_user=debian
    %{endfor~}
  DYN

  provisioner "remote-exec" {
    inline = ["echo 'SSH is alive'"]
    connection {
      type = "ssh"
      user = "debian"
      private_key = file("~/ssh_key")
      host = openstack_compute_instance_v2.instance.network[0].fixed_ip_v4
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -T 600 -i dyn-inventory --private-key=~/ssh_key ../../ansible/wdrozenie.yml --vault-password-file=~/.vault"
  }
}