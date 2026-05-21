# Main VPC for the assignment environment
resource "aws_vpc" "assignment_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "assignment-vpc"
  }
}

# Public subnet used for API exposure
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.assignment_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# Private subnet used by internal workers
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.assignment_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet"
  }
}

# Internet access for public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.assignment_vpc.id

  tags = {
    Name = "assignment-igw"
  }
}

# Route table for public internet traffic
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.assignment_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate public subnet with internet route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}