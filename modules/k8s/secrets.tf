resource "kubernetes_secret" "db_credentials" {
  count = var.core_cluster ? 1 : 0

  metadata {
    name      = "db"
    namespace = kubernetes_namespace.vcl_core.metadata.0.name
  }

  data = {
    connection_string = "psql://${var.db_username}:${var.db_user_password}@${var.db_host}:${var.db_port}/${var.db_name}"
  }
}

resource "kubernetes_secret" "redis_credentials" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.vcl_core.metadata.0.name
  }

  data = {
    host              = var.redis_host
    celery_broker_url = "redis://${var.redis_host}:6379/0"
  }
}

resource "kubernetes_secret" "rabbitmq_credentials" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.vcl_core.metadata.0.name
  }

  data = {
    url         = "${var.rabbitmq_host},5671,/"
    credentials = "${var.rabbitmq_username},${var.rabbitmq_password}"
  }
}
