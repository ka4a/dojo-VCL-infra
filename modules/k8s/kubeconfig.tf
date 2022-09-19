locals {
  kubeconfig_filename = "kubeconfig_${var.aws_eks_cluster_name}"
}

resource "null_resource" "kubeconfig" {

  triggers = {
    vcl_web_tgb_manifest_template_namespace        = local.vcl_web_tgb_manifest_template_values.namespace
    vcl_web_tgb_manifest_template_service_name     = local.vcl_web_tgb_manifest_template_values.service_name
    vcl_web_tgb_manifest_template_service_port     = local.vcl_web_tgb_manifest_template_values.service_port
    vcl_web_tgb_manifest_template_target_group_arn = local.vcl_web_tgb_manifest_template_values.target_group_arn
    vcl_web_tgb_manifest_template_tgb_name         = local.vcl_web_tgb_manifest_template_values.tgb_name

    traefik_tgb_manifest_template_namespace        = local.traefik_tgb_manifest_template_values.namespace
    traefik_tgb_manifest_template_service_name     = local.traefik_tgb_manifest_template_values.service_name
    traefik_tgb_manifest_template_service_port     = local.traefik_tgb_manifest_template_values.service_port
    traefik_tgb_manifest_template_target_group_arn = local.traefik_tgb_manifest_template_values.target_group_arn
    traefik_tgb_manifest_template_tgb_name         = local.traefik_tgb_manifest_template_values.tgb_name
  }

  provisioner "local-exec" {
    working_dir = path.module

    command = "aws eks update-kubeconfig --name ${var.aws_eks_cluster_name} --alias ${var.aws_eks_cluster_name} --kubeconfig ${local.kubeconfig_filename}"
  }
}
