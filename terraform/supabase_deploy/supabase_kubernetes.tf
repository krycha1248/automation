resource "kubernetes_namespace" "supabase-dev-namespace" {
  metadata {
    name = "supabase-dev"
  }

  depends_on = [
    ovh_cloud_project_kube.kubernetes_cluster
  ]
}

# resource "helm_release" "supabase-dev-helm" {
#   chart = "supabase"
#   name = "supabase"
#   namespace = kubernetes_namespace.supabase-dev-namespace.metadata.0.name
#   repository = "https://github.com/supabase-community/"
#   values = "${templatefile("vault.tftpl", {

#             })}"
# }

# resource "kubernetes_deployment" "supabase-dev-deployment" {
#   metadata {
#     name = "supabase-dev-deployment"
#     namespace = kubernetes_namespace.supabase-dev-namespace.metadata.0.name
#     labels = {
#       "app" = kubernetes_namespace.supabase-dev-namespace.metadata.0.name
#     }
#   }

#   spec {
#     replicas = 3
#     selector {
#       match_labels = {
#         "app" = kubernetes_namespace.supabase-dev-namespace.metadata.0.name
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           "app" = kubernetes_namespace.supabase-dev-namespace.metadata.0.name
#         }
#       }
#       spec {
#         container {
#           image = "bitnami/supabase-studio"
#           name = kubernetes_namespace.supabase-dev-namespace.metadata.0.name
#         }
#       }
#     }
#   }
# }