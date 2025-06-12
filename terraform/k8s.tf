# ./k8s.tf

# Criação do Namespace (stage ou production)
resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.environment
  }
}

# --- Recursos do Banco de Dados (MySQL) ---
resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  metadata {
    name      = "mysql-pvc"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_secret" "db_secret" {
  metadata {
    name      = "db-secret"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  data = {
    MYSQL_ROOT_PASSWORD = "bXlzcWw=" # mysql
    MYSQL_DATABASE      = "dGFza3NfZGI=" # tasks_db
    MYSQL_USER          = "bXlzcWw=" # mysql
    MYSQL_PASSWORD      = "bXlzcWw=" # mysql
  }
  type = "Opaque"
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = "mysql"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mysql"
      }
    }
    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }
      spec {
        container {
          name  = "mysql"
          image = "mysql:8.0"
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_secret.metadata[0].name
                key  = "MYSQL_ROOT_PASSWORD"
              }
            }
          }
          # Repetir 'env' para MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD
          # ...
          volume_mount {
            name       = "mysql-storage"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mysql-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "db_service" {
  metadata {
    name      = "db-service"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.mysql.spec[0].selector[0].match_labels.app
    }
    port {
      port        = 3306
      target_port = 3306
    }
    type = "ClusterIP"
  }
}

# --- Recursos do Backend ---
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "backend"
        }
      }
      spec {
        container {
          name  = "backend"
          image = "us-docker.pkg.dev/${var.gcp_project_id}/${var.back_repo}/${var.image_repo_back}:${var.image_tag}"
          port {
            container_port = 3000
          }
          env {
            name = "DB_HOST"
            value = kubernetes_service.db_service.metadata[0].name
          }
          # Repetir 'env' com 'value_from' para DB_USER, DB_PASSWORD, DB_DATABASE
          # ...
        }
      }
    }
  }
}

resource "kubernetes_service" "backend_service" {
  metadata {
    name      = "backend-service"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.backend.spec[0].selector[0].match_labels.app
    }
    port {
      port        = 3000
      target_port = 3000
    }
    type = "ClusterIP"
  }
}

# --- Recursos do Frontend ---
resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }
      spec {
        container {
          name  = "frontend"
          image = "us-docker.pkg.dev/${var.gcp_project_id}/${var.front_repo}/${var.image_repo_front}:${var.image_tag}"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend_service" {
  metadata {
    name      = "frontend-service"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.frontend.spec[0].selector[0].match_labels.app
    }
    port {
      port        = 80
      target_port = 80
      node_port   = var.env_specifics[var.environment].frontend_node_port
    }
    type = "NodePort"
  }
}

# --- Recursos de Rede e Exposição (Ingress) ---

# O ManagedCertificate é um CRD do GKE. Usamos o recurso kubernetes_manifest para criá-lo.
resource "kubernetes_manifest" "managed_cert" {
  manifest = {
    "apiVersion" = "networking.gke.io/v1"
    "kind"       = "ManagedCertificate"
    "metadata" = {
      "name"      = "${var.environment}-cert"
      "namespace" = kubernetes_namespace.ns.metadata[0].name
    }
    "spec" = {
      "domains" = [
        var.env_specifics[var.environment].domain
      ]
    }
  }
}

resource "kubernetes_ingress_v1" "frontend_ingress" {
  metadata {
    name      = "frontend-ingress"
    namespace = kubernetes_namespace.ns.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = var.env_specifics[var.environment].static_ip_name
      "networking.gke.io/managed-certificates"      = kubernetes_manifest.managed_cert.object.metadata.name
      "kubernetes.io/ingress.class"                 = "gce"
    }
  }
  spec {
    rule {
      host = var.env_specifics[var.environment].domain
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.frontend_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# --- Políticas de Rede (Network Policies) ---

resource "kubernetes_network_policy" "allow_backend_to_mysql" {
  metadata {
    name      = "allow-backend-to-mysql"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    pod_selector {
      match_labels = {
        app = "mysql"
      }
    }
    policy_types = ["Ingress"]
    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "backend"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 3306
      }
    }
  }
}

resource "kubernetes_network_policy" "allow_frontend_to_backend" {
  metadata {
    name = "allow-frontend-to-backend"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    pod_selector {
      match_labels = {
        app = "backend"
      }
    }
    policy_types = ["Ingress"]
    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "frontend"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = 3000
      }
    }
  }
}

resource "kubernetes_network_policy" "allow_all_to_frontend" {
    metadata {
    name = "allow-all-to-frontend"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    pod_selector {
        match_labels = {
            app = "frontend"
        }
    }
    policy_types = ["Ingress"]
    ingress {} # O bloco vazio permite todo o tráfego de entrada
  }
}