resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.vpc_dns_hostnames
  enable_dns_support   = var.vpc_dns_support

  tags = merge(var.tags, {
    "Name" = var.name_prefix
  })
}

# Subnets
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_public_a
  availability_zone = local.aws_az_a

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-${local.aws_az_a}-public"
  })
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_public_c
  availability_zone = local.aws_az_c

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-${local.aws_az_c}-public"
  })
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_private_a
  availability_zone = local.aws_az_a

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-${local.aws_az_a}-private"
  })
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_private_c
  availability_zone = local.aws_az_c

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-${local.aws_az_c}-private"
  })
}

# Egress
resource "aws_eip" "this" {
  vpc = true

  tags = merge(var.tags, {
    "Name" = var.name_prefix
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-${local.aws_az_a}"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    "Name" = var.name_prefix
  })
}

# Route Tables
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-private"
  })
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    "Name" = "${var.name_prefix}-public"
  })
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id
}
