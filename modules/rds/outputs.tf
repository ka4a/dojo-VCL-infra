output "db_username" {
  value = aws_db_instance.default.username
}

output "db_user_password" {
  sensitive = true
  value     = aws_db_instance.default.password
}

output "db_host" {
  value = aws_db_instance.default.address
}

output "db_port" {
  value = aws_db_instance.default.port
}

output "db_name" {
  value = aws_db_instance.default.name
}

