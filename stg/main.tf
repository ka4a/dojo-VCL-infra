module "ecr_web" {
  source                       = "../modules/ecr"
  name                         = "vcl_web"
  ecr_repository_policy        = data.aws_iam_policy_document.ecr_common.json
  enable_ecr_repository_policy = true
  enable_ecr_lifecycle_policy  = true
  enable_ecr_repository        = true

  tags = local.tags
}

module "ecr_watcher" {
  source                       = "../modules/ecr"
  name                         = "vcl_watcher"
  ecr_repository_policy        = data.aws_iam_policy_document.ecr_common.json
  enable_ecr_repository_policy = true
  enable_ecr_lifecycle_policy  = true
  enable_ecr_repository        = true

  tags = local.tags
}

module "ecr_init_container" {
  source                       = "../modules/ecr"
  name                         = "vcl_init_container"
  ecr_repository_policy        = data.aws_iam_policy_document.ecr_common.json
  enable_ecr_repository_policy = true
  enable_ecr_lifecycle_policy  = true
  enable_ecr_repository        = true

  tags = local.tags
}

module "ecr_consumer" {
  source                       = "../modules/ecr"
  name                         = "vcl_consumer"
  ecr_repository_policy        = data.aws_iam_policy_document.ecr_common.json
  enable_ecr_repository_policy = true
  enable_ecr_lifecycle_policy  = true
  enable_ecr_repository        = true

  tags = local.tags
}

module "ecr_celery" {
  source                       = "../modules/ecr"
  name                         = "vcl_celery"
  ecr_repository_policy        = data.aws_iam_policy_document.ecr_common.json
  enable_ecr_repository_policy = true
  enable_ecr_lifecycle_policy  = true
  enable_ecr_repository        = true

  tags = local.tags
}

module "ecr_beat" {
  source                       = "../modules/ecr"
  name                         = "vcl_beat"
  ecr_repository_policy        = data.aws_iam_policy_document.ecr_common.json
  enable_ecr_repository_policy = true
  enable_ecr_lifecycle_policy  = true
  enable_ecr_repository        = true

  tags = local.tags
}

module "ecr_coding_environments" {
  source                       = "../modules/ecr"
  name                         = "vcl_coding_environments"
  ecr_repository_policy        = data.aws_iam_policy_document.ecr_common.json
  enable_ecr_repository_policy = true
  enable_ecr_lifecycle_policy  = true
  enable_ecr_repository        = true

  tags = local.tags
}

module "ecr_ws_supervisor" {
  source                       = "../modules/ecr"
  name                         = "vcl_ws_supervisor"
  ecr_repository_policy        = data.aws_iam_policy_document.ecr_common.json
  enable_ecr_repository_policy = true
  enable_ecr_lifecycle_policy  = true
  enable_ecr_repository        = true

  tags = local.tags
}

module "vpc" {
  source = "../modules/vpc"

  name_prefix = local.name_prefix

  subnet_cidr_public_a  = local.subnet_cidr_public_a
  subnet_cidr_public_c  = local.subnet_cidr_public_c
  subnet_cidr_private_a = local.subnet_cidr_private_a
  subnet_cidr_private_c = local.subnet_cidr_private_c
  vpc_cidr              = local.vpc_cidr

  tags = local.tags
}

module "eks_cluster_iam_role" {
  source = "../modules/iam_role"

  environment = var.env
  # Using IAM role
  enable_iam_role             = true
  iam_role_name               = "${local.name_prefix}-eks-cluster"
  iam_role_description        = "IAM Role for EKS clusters"
  iam_role_assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json

  iam_role_force_detach_policies = true
  iam_role_path                  = "/"
  iam_role_max_session_duration  = 3600

  # Using IAM role policy attachment
  enable_iam_role_policy_attachment      = true
  iam_role_policy_attachment_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy", "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"]

  tags = local.tags
}

module "eks_node_group_iam_role" {
  source = "../modules/iam_role"

  environment = var.env

  # Using IAM role
  enable_iam_role             = true
  iam_role_name               = "${local.name_prefix}-eks-node-group"
  iam_role_description        = "IAM Role for EKS node group"
  iam_role_assume_role_policy = data.aws_iam_policy_document.eks_node_group_assume_role.json

  iam_role_force_detach_policies = true
  iam_role_path                  = "/"
  iam_role_max_session_duration  = 3600

  # Using IAM role policy attachment
  enable_iam_role_policy_attachment      = true
  iam_role_policy_attachment_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]

  tags = local.tags
}
#
module "eks_core" {
  source = "../modules/eks"

  environment  = var.env
  core_cluster = true
  vpc_cidr     = module.vpc.vpc_cidr
  vpc_id       = module.vpc.vpc_id

  # Create AWS EKS cluster
  create_eks_cluster   = true
  eks_cluster_name     = "vcl-core-${var.env}"
  eks_cluster_role_arn = module.eks_cluster_iam_role.iam_role_arn

  eks_cluster_enabled_cluster_log_types = ["api", "audit", "authenticator"]
  eks_cluster_version                   = null

  eks_cluster_vpc_config = [
    {
      subnet_ids = module.vpc.private_subnet_ids

      public_access_cidrs     = null
      endpoint_private_access = true
      endpoint_public_access  = true
      security_group_ids      = null
    }
  ]

  eks_cluster_encryption_config = []

  # AWS EKS NodeGroup
  eks_node_groups = [
    {
      # system EKS node-group
      name             = "system"
      role_arn         = module.eks_node_group_iam_role.iam_role_arn
      subnet_ids       = module.vpc.private_subnet_ids
      ami_type         = "AL2_x86_64"
      disk_size        = 20
      instance_types   = ["t3.small"]
      asg_max_size     = 3
      asg_desired_size = 1
      asg_min_size     = 1
    },
    {
      # application EKS node-group
      name             = "application"
      role_arn         = module.eks_node_group_iam_role.iam_role_arn
      subnet_ids       = [module.vpc.private_subnet_ids[0]]
      ami_type         = "AL2_x86_64"
      disk_size        = 20
      instance_types   = ["t3.medium"]
      asg_max_size     = 3
      asg_desired_size = 1
      asg_min_size     = 1
    }
  ]

  tags = local.tags
}

module "eks_workspaces" {
  source = "../modules/eks"

  environment = var.env
  vpc_cidr    = module.vpc.vpc_cidr
  vpc_id      = module.vpc.vpc_id

  # Create AWS EKS cluster
  create_eks_cluster   = true
  eks_cluster_name     = "vcl-workspaces-${var.env}"
  eks_cluster_role_arn = module.eks_cluster_iam_role.iam_role_arn

  eks_cluster_enabled_cluster_log_types = ["api", "audit", "authenticator"]
  eks_cluster_version                   = null

  eks_cluster_vpc_config = [
    {
      subnet_ids = module.vpc.private_subnet_ids

      public_access_cidrs     = null
      endpoint_private_access = true
      endpoint_public_access  = true
      security_group_ids      = null
    }
  ]

  eks_cluster_encryption_config = []

  # AWS EKS NodeGroup
  eks_node_groups = [
    {
      # system EKS node-group
      name             = "system"
      role_arn         = module.eks_node_group_iam_role.iam_role_arn
      subnet_ids       = module.vpc.private_subnet_ids
      ami_type         = "AL2_x86_64"
      disk_size        = 20
      instance_types   = ["t3.small"]
      asg_max_size     = 3
      asg_desired_size = 1
      asg_min_size     = 1
      labels           = { "withGPU" = "false" }
    },
    {
      # CPU only EKS node-group
      name             = "cpu-workspaces"
      role_arn         = module.eks_node_group_iam_role.iam_role_arn
      subnet_ids       = [module.vpc.private_subnet_ids[0]]
      ami_type         = "AL2_x86_64"
      disk_size        = 20
      instance_types   = ["c6i.xlarge", "c5.xlarge"]
      asg_max_size     = 5
      asg_desired_size = 1
      asg_min_size     = 1
      labels           = { "withGPU" = "false" }
    },
    {
      # GPU only EKS node-group
      name             = "gpu-workspaces"
      role_arn         = module.eks_node_group_iam_role.iam_role_arn
      subnet_ids       = [module.vpc.private_subnet_ids[0]]
      ami_type         = "AL2_x86_64_GPU"
      disk_size        = 40
      instance_types   = ["g4dn.xlarge"]
      asg_max_size     = 3
      asg_desired_size = 0
      asg_min_size     = 0
      labels = {
        "withGPU"                       = "true",
        "k8s.amazonaws.com/accelerator" = "nvidia-tesla-t4"
      }
    },
    {
      # application EKS node-group
      name             = "application"
      role_arn         = module.eks_node_group_iam_role.iam_role_arn
      subnet_ids       = [module.vpc.private_subnet_ids[0]]
      ami_type         = "AL2_x86_64"
      disk_size        = 20
      instance_types   = ["t3.medium"]
      asg_max_size     = 3
      asg_desired_size = 1
      asg_min_size     = 1
      labels           = { "withGPU" = "false" }
    }
  ]

  tags = local.tags
}

module "rabbitmq" {
  source = "../modules/rabbitmq/"

  environment = var.env

  # MQ config
  enable_mq_configuration = false

  # MQ broker
  enable_mq_broker             = true
  broker_name                  = "${local.name_prefix}-rabbitmq"
  mq_broker_engine_type        = "RabbitMQ"
  mq_broker_host_instance_type = "mq.t3.micro"

  mq_broker_security_group_ids = [module.vpc.rabbitmq_sg_id]
  mq_broker_subnet_ids         = module.vpc.private_subnet_ids

  mq_broker_logs = {
    general = true
  }

  mq_broker_maintenance_window_start_time = {
    day_of_week = "MONDAY"
    time_of_day = "02:00"
    time_zone   = "UTC"
  }

  mq_broker_users = [
    {
      username = "mq_broker"
      password = var.rabbit_password
    }
  ]

  tags = local.tags
}

module "rds" {
  source = "../modules/rds"

  name_prefix = local.name_prefix

  identifier            = "${local.name_prefix}-db"
  db_name               = "vcl"
  username              = "vcluser"
  password              = var.pg_password
  storage               = "10"
  engine                = "postgres"
  engine_version        = "13.5"
  instance_class        = "db.t3.micro"
  private_net_ids       = module.vpc.private_subnet_ids
  environment           = var.env
  vpc_id                = module.vpc.vpc_id
  rds_security_group_id = module.vpc.postgresql_sg_id

  tags = local.tags
}

module "cache" {
  source = "../modules/redis"

  name_prefix = local.name_prefix

  cluster_id         = "${local.name_prefix}-cache"
  environment        = var.env
  private_net_ids    = module.vpc.private_subnet_ids
  redis_version      = "6.x"
  redis_node_type    = "cache.t3.micro"
  security_group_ids = [module.vpc.redis_sg_id]
  vpc_id             = module.vpc.vpc_id

  tags = local.tags
}

module "k8s_system_services" {
  source = "../modules/k8s"

  aws_eks_cluster_certificate_authority_data_base64 = data.aws_eks_cluster.vcl_core.certificate_authority[0].data
  aws_eks_cluster_endpoint                          = data.aws_eks_cluster.vcl_core.endpoint
  aws_eks_cluster_name                              = data.aws_eks_cluster.vcl_core.name
  aws_eks_cluster_oidc_issuer_url                   = module.eks_core.eks_cluster_oidc_issuer_url
  oidc_provider_arn                                 = module.eks_core.oidc_provider_arn
  aws_account_id                                    = data.aws_caller_identity.current.account_id
  vcl_web_sa_iam_role_arn                           = module.eks_core.vcl_web_sa_iam_role_arn
  eks_node_group_iam_role                           = module.eks_node_group_iam_role.iam_role_name
  core_cluster                                      = true
  gpu_nodes                                         = false

  aws_auth_map_roles = [
    {
      groups   = ["system:masters"]
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole"
      username = "OrganizationAccountAccessRole"
    },
    {
      groups   = ["system:masters"]
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/vcl-oidc-role"
      username = "GithubAccessRole"
    }
  ]

  aws_auth_map_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/vm"
      username = "vm"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/rehan"
      username = "rehan"
      groups   = ["system:masters"]
    }
  ]

  db_host          = module.rds.db_host
  db_port          = module.rds.db_port
  db_name          = module.rds.db_name
  db_username      = module.rds.db_username
  db_user_password = var.pg_password

  redis_host = module.cache.redis_nodes[0].address

  rabbitmq_host     = trimprefix(module.rabbitmq.mq_broker_instances[0].console_url, "https://")
  rabbitmq_username = "mq_broker"
  rabbitmq_password = var.rabbit_password

  tgb_target_group_arn = module.vcl_alb.vcl_core_target_group_arn

  tags = local.tags
}

module "vcl_workspaces_k8s_system_services" {
  source = "../modules/k8s"

  aws_eks_cluster_certificate_authority_data_base64 = data.aws_eks_cluster.vcl_workspaces.certificate_authority[0].data
  aws_eks_cluster_endpoint                          = data.aws_eks_cluster.vcl_workspaces.endpoint
  aws_eks_cluster_name                              = data.aws_eks_cluster.vcl_workspaces.name
  aws_eks_cluster_oidc_issuer_url                   = module.eks_workspaces.eks_cluster_oidc_issuer_url
  oidc_provider_arn                                 = module.eks_workspaces.oidc_provider_arn
  aws_account_id                                    = data.aws_caller_identity.current.account_id
  eks_node_group_iam_role                           = module.eks_node_group_iam_role.iam_role_name
  tgb_target_group_arn                              = module.vcl_alb.vcl_workspaces_target_group_arn
  gpu_nodes                                         = true
  ghost_cpu_enabled                                 = true

  aws_auth_map_roles = [
    {
      groups   = ["system:masters"]
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole"
      username = "OrganizationAccountAccessRole"
    },
    {
      groups   = ["system:masters"]
      rolearn  = module.eks_core.vcl_web_sa_iam_role_arn
      username = "vcl-core"
    },
    {
      groups   = ["system:masters"]
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/vcl-oidc-role"
      username = "GithubAccessRole"
    }
  ]

  aws_auth_map_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/vm"
      username = "vm"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/rehan"
      username = "rehan"
      groups   = ["system:masters"]
    }
  ]

  rabbitmq_host     = trimprefix(module.rabbitmq.mq_broker_instances[0].console_url, "https://")
  rabbitmq_username = "mq_broker"
  rabbitmq_password = var.rabbit_password

  tags = local.tags
}

module "vcl_alb" {
  source = "../modules/elb"

  name            = "${local.name_prefix}-alb"
  env             = var.env
  internal        = false
  security_groups = [module.vpc.alb_public_sg_id]
  subnets         = module.vpc.public_subnet_ids
  vpc_id          = module.vpc.vpc_id

  acm_arn                     = data.aws_acm_certificate.acm.arn
  domain_name                 = var.domain_name
  fully_qualified_domain_name = "${var.vcl_web_sub_domain_name}.${var.domain_name}"

  tags = local.tags
}
