# Security group for public API instance
resource "aws_security_group" "api_sg" {
  name        = "api-security-group"
  description = "Allows SSH and HTTP traffic"
  vpc_id      = aws_vpc.assignment_vpc.id

  ingress {
    description = "SSH from local machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["223.233.84.221/32"]
  }

  ingress {
    description = "Public HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "FastAPI access"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "api-sg"
  }
}

# Security group for internal workers
resource "aws_security_group" "worker_sg" {
  name        = "worker-security-group"
  description = "Internal worker communication only"
  vpc_id      = aws_vpc.assignment_vpc.id

  ingress {
    description = "Internal VPC communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"

    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "SSH from API subnet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "worker-sg"
  }
}