terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }

    ovh = {
      source = "ovh/ovh"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/"
  domain_name = "default"
  alias       = "ovh"
}

provider "ovh" {
  alias    = "ovh"
  endpoint = "ovh-eu"
}

provider "cloudflare" {
  api_token = var.cf_api_token
}