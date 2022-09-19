# Learn Terraform - Provision an EKS Cluster

This repo contains Terraform configuration files to [Provision an EKS Cluster](https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster).

Please add variables.  
export AWS_DEFAULT_REGION=ap-northeast-1  
export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXX  
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  
export TF_VAR_pg_password="xxxx"  
export TF_VAR_rabbit_password="xxx"

Pre-install tools - kubectl, awscli, aws-iam-authenticator, wget.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | 4.8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cache"></a> [cache](#module_cache) | ../modules/redis | n/a |
| <a name="module_ecr_beat"></a> [ecr_beat](#module_ecr_beat) | ../modules/ecr | n/a |
| <a name="module_ecr_celery"></a> [ecr_celery](#module_ecr_celery) | ../modules/ecr | n/a |
| <a name="module_ecr_coding_environments"></a> [ecr_coding_environments](#module_ecr_coding_environments) | ../modules/ecr | n/a |
| <a name="module_ecr_consumer"></a> [ecr_consumer](#module_ecr_consumer) | ../modules/ecr | n/a |
| <a name="module_ecr_init_container"></a> [ecr_init_container](#module_ecr_init_container) | ../modules/ecr | n/a |
| <a name="module_ecr_watcher"></a> [ecr_watcher](#module_ecr_watcher) | ../modules/ecr | n/a |
| <a name="module_ecr_web"></a> [ecr_web](#module_ecr_web) | ../modules/ecr | n/a |
| <a name="module_eks_cluster_iam_role"></a> [eks_cluster_iam_role](#module_eks_cluster_iam_role) | ../modules/iam_role | n/a |
| <a name="module_eks_core"></a> [eks_core](#module_eks_core) | ../modules/eks | n/a |
| <a name="module_eks_node_group_iam_role"></a> [eks_node_group_iam_role](#module_eks_node_group_iam_role) | ../modules/iam_role | n/a |
| <a name="module_eks_workspaces"></a> [eks_workspaces](#module_eks_workspaces) | ../modules/eks | n/a |
| <a name="module_k8s_system_services"></a> [k8s_system_services](#module_k8s_system_services) | ../modules/k8s | n/a |
| <a name="module_my_rds"></a> [my_rds](#module_my_rds) | ../modules/rds | n/a |
| <a name="module_rabbitmq"></a> [rabbitmq](#module_rabbitmq) | ../modules/rabbitmq/ | n/a |
| <a name="module_vcl_alb"></a> [vcl_alb](#module_vcl_alb) | ../modules/elb | n/a |
| <a name="module_vcl_workspaces_k8s_system_services"></a> [vcl_workspaces_k8s_system_services](#module_vcl_workspaces_k8s_system_services) | ../modules/k8s | n/a |
| <a name="module_vpc"></a> [vpc](#module_vpc) | ../modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.acm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.vcl_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster.vcl_workspaces](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_policy_document.ecr_common](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eks_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eks_node_group_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pg_password"></a> [pg_password](#input_pg_password) | RDS Postgres Password | `string` | n/a | yes |
| <a name="input_rabbit_password"></a> [rabbit_password](#input_rabbit_password) | Rabbit Password | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain_name](#input_domain_name) | n/a | `string` | `"dojoide.com"` | no |
| <a name="input_ecr_allow_pull_entities"></a> [ecr_allow_pull_entities](#input_ecr_allow_pull_entities) | n/a | `string` | `"arn:aws:iam::762006128434:root"` | no |
| <a name="input_ecr_allow_push_entities"></a> [ecr_allow_push_entities](#input_ecr_allow_push_entities) | n/a | `string` | `"arn:aws:iam::762006128434:user/vcl_ecr_pusher"` | no |
| <a name="input_env"></a> [env](#input_env) | Environment name | `string` | `"stg"` | no |
| <a name="input_project"></a> [project](#input_project) | n/a | `string` | `"vcl"` | no |
| <a name="input_vcl_web_sub_domain_name"></a> [vcl_web_sub_domain_name](#input_vcl_web_sub_domain_name) | n/a | `string` | `"staging"` | no |
<!-- END_TF_DOCS -->
