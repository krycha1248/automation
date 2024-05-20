resource "ovh_cloud_project_kube" "kubernetes_cluster" {
   service_name = var.ovh_service_name
   name         = "Kubernetes cluster"
   region       = "WAW1"
   version      = "1.29"
}

resource "ovh_cloud_project_kube_nodepool" "node_pool_d2_4" {
   service_name  = var.ovh_service_name
   kube_id       = ovh_cloud_project_kube.kubernetes_cluster.id
   name          = "workers-d2-4"
   flavor_name   = "d2-4"
   desired_nodes = 1
   max_nodes     = 2
   min_nodes     = 1
}

data "http" "public_ip" {
    url = "https://ipv4.icanhazip.com"
}

resource "ovh_cloud_project_kube_iprestrictions" "security_policy" {
  service_name = var.ovh_service_name
  kube_id      = ovh_cloud_project_kube.kubernetes_cluster.id
  ips          = ["${chomp(data.http.public_ip.response_body)}/32"]
}

resource "local_file" "kube_config_file" {
    content         = ovh_cloud_project_kube.kubernetes_cluster.kubeconfig
    filename        = pathexpand("~/.kube/config")
    file_permission = 0640
}