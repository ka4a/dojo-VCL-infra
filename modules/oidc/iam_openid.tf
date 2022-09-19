#---------------------------------------------------
# Access to AWS for GitHub Actions through OIDC 2.0
#---------------------------------------------------
resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = var.thumbprint
}