# SSH key uploaded to AWS
resource "aws_key_pair" "assignment_key" {
  key_name   = "assignment-key"
  public_key = file("C:/Users/tanuj/.ssh/id_ed25519.pub")
}

# Public API instance
resource "aws_instance" "api_vm" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.api_sg.id]
  key_name               = aws_key_pair.assignment_key.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "api-vm"
    Role = "api-gateway"
  }
}

# TypeScript caller worker
resource "aws_instance" "caller_worker_vm" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "c7i-flex.large"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
  key_name               = aws_key_pair.assignment_key.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "caller-worker-vm"
    Role = "caller-worker"
  }
}

# Python inference worker
resource "aws_instance" "inference_worker_vm" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "c7i-flex.large"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]
  key_name               = aws_key_pair.assignment_key.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "inference-worker-vm"
    Role = "inference-worker"
  }
}