output "vcl_core_target_group_arn" {
  value = aws_lb_target_group.vcl_core.arn
}

output "vcl_workspaces_target_group_arn" {
  value = aws_lb_target_group.vcl_workspaces.arn
}
