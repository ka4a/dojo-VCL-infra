variable "aws_eks_cluster_endpoint" {}

variable "aws_eks_cluster_certificate_authority_data_base64" {}

variable "aws_eks_cluster_name" {}

variable "aws_eks_cluster_oidc_issuer_url" {}

variable "oidc_provider_arn" {}

variable "aws_account_id" {
  default = null
}

variable "eks_node_group_iam_role" {
  default = null
}

variable "eks_node_group_depends_on" {
  default = []
}

variable "tags" {
  default = {}
}

variable "core_cluster" {
  default = false
}

variable "vcl_web_sa_iam_role_arn" {
  default = null
}

variable "manage_aws_auth" {
  description = "Whether to apply the aws-auth configmap file."
  default     = true
}

variable "aws_auth_map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "tgb_target_group_arn" {}

variable "system_namespace" {
  description = "Kubernetes namespace name for System services"
  type        = string
  default     = "vcl-system"
}

variable "metrics_server_config" {
  description = "metrics-server Helm Chart configuration variables"
  type = object({
    chart_version       = string
    image_repo          = string
    image_tag           = string
    deployment_replicas = number
    rbac_create         = bool
    node_selector       = map(string)
  })
  default = {
    chart_version       = "3.8.1"
    image_repo          = "k8s.gcr.io/metrics-server/metrics-server"
    image_tag           = "v0.6.1"
    deployment_replicas = 1
    rbac_create         = true
    node_selector = {
      "eks.amazonaws.com/nodegroup" = "system"
    }
  }
}

variable "nvidia_device_plugin_config" {
  description = "nvidia-device-plugin Helm Chart configuration variables"
  type = object({
    chart_version = string
    image_repo    = string
    image_tag     = string
    node_selector = map(string)
  })
  default = {
    chart_version = "0.11.0"
    image_repo    = "nvcr.io/nvidia/k8s-device-plugin"
    image_tag     = "v0.11.0"
    node_selector = {
      "eks.amazonaws.com/nodegroup" = "gpu-workspaces"
    }
  }
}

variable "gpu_nodes" {
  default = false
}

variable "cluster_autoscaler_plugin_config" {
  description = "Cluster Autoscaler Helm Chart configuration variables"
  type = object({
    chart_version       = string
    image_repo          = string
    image_tag           = string
    deployment_replicas = number
    service_account     = string
    aws_region          = string
    node_selector       = map(string)
  })
  default = {
    chart_version       = "9.15.0"
    image_repo          = "k8s.gcr.io/autoscaling/cluster-autoscaler"
    image_tag           = "v1.23.0"
    deployment_replicas = 1
    service_account     = "cluster-autoscaler"
    aws_region          = "ap-northeast-1"
    node_selector = {
      "eks.amazonaws.com/nodegroup" = "system"
    }
  }
}

variable "aws_lb_controller_config" {
  description = "Cluster Autoscaler Helm Chart configuration variables"
  type = object({
    chart_version        = string
    deployment_replicas  = number
    service_account      = string
    aws_region           = string
    controller_resources = map(map(string))
    node_selector        = map(string)
  })
  default = {
    chart_version       = "1.4.0"
    deployment_replicas = 1
    service_account     = "aws-lb-controller"
    aws_region          = "ap-northeast-1"
    controller_resources = {
      requests = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }
    node_selector = {
      "eks.amazonaws.com/nodegroup" = "system"
    }
  }
}

variable "traefik_config" {
  description = "Traefik Helm Chart configuration variables"
  type = object({
    chart_version       = string
    deployment_replicas = number
    service_account     = string
    resources           = map(map(string))
    node_selector       = map(string)
  })
  default = {
    chart_version       = "10.23.0"
    deployment_replicas = 1
    service_account     = "traefik"
    resources = {
      requests = {
        cpu    = "100m"
        memory = "50Mi"
      }
    }
    node_selector = {
      "eks.amazonaws.com/nodegroup" = "system"
    }
  }
}

variable "db_username" {
  default = null
}

variable "db_user_password" {
  default = null
}

variable "db_host" {
  default = null
}

variable "db_port" {
  default = null
}

variable "db_name" {
  default = null
}

variable "redis_host" {
  default = null
}

variable "rabbitmq_host" {
  default = null
}

variable "rabbitmq_username" {
  default = null
}

variable "rabbitmq_password" {
  default = null
}

variable "ghost_cpu_enabled" {
  type    = bool
  default = false
}

variable "ghost_cpu_replicas" {
  type    = number
  default = 4
}

variable "ghost_cpu_resources" {
  type    = string
  default = "900m"
}

# DataDog Agent
variable "datadog_enabled" {
  description = "Whether to deploy DataDog Agent."
  type        = bool
  default     = true
}

variable "datadog_chart_version" {
  description = "DataDog Agent Helm Chart version."
  type        = string
  default     = "2.35.5"
}

variable "datadog_api_key" {
  description = "DataDog Agent API key."
  type        = string
  sensitive   = true
  default     = null
}

variable "datadog_cluster_agent_replicas" {
  description = "Specify the of cluster agent replicas, if > 1 it allow the cluster agent to work in HA mode."
  type        = number
  default     = 1
}

variable "datadog_cluster_agent_node_selector" {
  description = "Allow the Cluster Agent Deployment to be scheduled on selected nodes."
  type        = map(string)
  default = {
    "eks.amazonaws.com/nodegroup" = "system"
  }
}

variable "datadog_logs_enabled" {
  description = "Enables this to activate Datadog Agent log collection."
  type        = string
  default     = "true"

  validation {
    condition     = var.datadog_logs_enabled == "true" || var.datadog_logs_enabled == "false"
    error_message = "The value must be \"true\" of \"false\"."
  }
}

variable "datadog_container_exclude" {
  description = "Exclude containers from the Agent Autodiscovery, as a space-separated list."
  type        = string
  default     = "kube_namespace:kube-system"
}

variable "datadog_container_include" {
  description = "Include containers in the Agent Autodiscovery, as a space-separated list. If a container matches an include rule, it’s always included in the Autodiscovery."
  type        = string
  default     = ""
}

variable "datadog_container_exclude_logs" {
  description = "Exclude logs from the Agent Autodiscovery, as a space-separated list."
  type        = string
  default     = "kube_namespace:vcl-system"
}

variable "datadog_container_include_logs" {
  description = "Include logs in the Agent Autodiscovery, as a space-separated list."
  type        = string
  default     = ""
}

variable "datadog_network_monitoring_enabled" {
  description = "Enable network performance monitoring."
  type        = string
  default     = "false"

  validation {
    condition     = var.datadog_network_monitoring_enabled == "true" || var.datadog_network_monitoring_enabled == "false"
    error_message = "The value must be \"true\" of \"false\"."
  }
}

variable "datadog_process_agent_enabled" {
  description = "Set this to true to enable live process monitoring agent"
  type        = string
  default     = "false"

  validation {
    condition     = var.datadog_process_agent_enabled == "true" || var.datadog_process_agent_enabled == "false"
    error_message = "The value must be \"true\" of \"false\"."
  }
}

variable "datadog_agent_confd" {
  # https://docs.datadoghq.com/agent/autodiscovery/
  description = "Provide additional check configurations (static and Autodiscovery). Each key becomes a file in /conf.d"
  type        = map(any)
  default     = {}
}
