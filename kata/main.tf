# Grupo de seguridad para las instancias EC2
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Permite trafico HTTP y SSH"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Instancias EC2
resource "aws_instance" "app" {
  count         = var.instance_count
  ami           = "ami-0fff1b9a61dec8a5f"  # AMI válida en us-east-1 para Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  associate_public_ip_address = true  # Mantén la IP pública para acceso a internet
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  availability_zone = "us-east-1b"

  iam_instance_profile = "EMR_EC2_DefaultRole"

  depends_on = [ aws_s3_bucket.bucket_for_file, aws_s3_object.file ]

  user_data = <<-EOF
    #!/bin/bash
    # Actualiza el sistema e instala Apache
    yum update -y
    yum install -y httpd

    # Descarga archivo desde S3 usando el VPC Endpoint
    aws s3 cp s3://${aws_s3_bucket.bucket_for_file.bucket}/index.html /var/www/html/index.html

        # Obtener la IP pública de la instancia
    INSTANCE_PUBLIC_IP=${count.index}

    # Reemplazar {public_ip} en el archivo de configuración neo4j.conf con la IP pública
    sudo sed -i "s/{index}/$INSTANCE_PUBLIC_IP/g" /var/www/html/index.html

    # Inicia Apache y habilita que arranque con el sistema
    systemctl start httpd
    systemctl enable httpd
  EOF

  tags = {
    Name = "AppInstance-${count.index}"
  }
}



# output instance public IPs
output "instance_public_ips" {
  value = aws_instance.app[*].public_ip
}


# ELB (Load Balancer)
#resource "aws_elb" "app_lb" {
#  name               = "app-lb"
#  availability_zones = ["us-east-1a", "us-east-1b"]
#  security_groups    = [aws_security_group.allow_http.id]
#
#  listener {
#    instance_port     = 80
#    instance_protocol = "HTTP"
#    lb_port           = 80
#    lb_protocol       = "HTTP"
#  }
#
#  health_check {
#    target              = "HTTP:80/"
#    interval            = 30
#    timeout             = 5
#    healthy_threshold   = 2
#    unhealthy_threshold = 2
#  }
#
#  instances = aws_instance.app[*].id
#
#  tags = {
#    Name = "AppLoadBalancer"
#  }
#}