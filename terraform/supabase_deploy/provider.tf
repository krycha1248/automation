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

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    helm = {
      source = "hashicorp/helm"
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

provider "kubernetes" {
  host                    = ovh_cloud_project_kube.kubernetes_cluster.kubeconfig_attributes[0].host
  client_certificate      = base64decode(ovh_cloud_project_kube.kubernetes_cluster.kubeconfig_attributes[0].client_certificate)
  client_key              = base64decode(ovh_cloud_project_kube.kubernetes_cluster.kubeconfig_attributes[0].client_key)
  cluster_ca_certificate  = base64decode(ovh_cloud_project_kube.kubernetes_cluster.kubeconfig_attributes[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                    = ovh_cloud_project_kube.kubernetes_cluster.kubeconfig_attributes[0].host
    client_certificate      = base64decode(ovh_cloud_project_kube.kubernetes_cluster.kubeconfig_attributes[0].client_certificate)
    client_key              = base64decode(ovh_cloud_project_kube.kubernetes_cluster.kubeconfig_attributes[0].client_key)
    cluster_ca_certificate  = base64decode(ovh_cloud_project_kube.kubernetes_cluster.kubeconfig_attributes[0].cluster_ca_certificate)
  }
}