# VPC creation
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Public subnet creation
resource "aws_subnet" "public" {
  vpc_id                = aws_vpc.main.id
  cidr_block            = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
}

# Internet Gateway creation
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  
}

# Route Table creation
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Route Table Association
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# VPC Endpoint for S3
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.s3"  # El servicio S3 en la región us-east-1

  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "S3-VPC-Endpoint"
  }
}