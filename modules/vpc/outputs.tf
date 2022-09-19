output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  value = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  value = [aws_subnet.public_a.id, aws_subnet.public_c.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_a.id, aws_subnet.private_c.id]
}

output "nat_gw_ip" {
  value = aws_nat_gateway.this.public_ip
}

output "rabbitmq_sg_id" {
  value = aws_security_group.rabbitmq.id
}

output "redis_sg_id" {
  value = aws_security_group.redis.id
}

output "postgresql_sg_id" {
  value = aws_security_group.postgresql.id
}

output "alb_public_sg_id" {
  value = aws_security_group.alb_public.id
}

output "alb_private_sg_id" {
  value = aws_security_group.alb_private.id
}
