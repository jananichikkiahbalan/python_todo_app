//Networking
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        name = "todo-vpc"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = "ap-south-1a"

    tags = {
        name = "todo-public-subnet"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
      name = "todo-igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      name = "todo-rt"
    }
}

resource "aws_route_table_association" "public_assoc" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public_rt.id
  
}

//security group
resource "aws_security_group" "web_sg" {
    name = "web_sg"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        name = "todo-sg"
    }
}

//IAM role
resource "aws_iam_role" "todo-ec2-role" {
    name = "todo-ec2-role"

    assume_role_policy = jsonencode({
            Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"   # who can assume this role
        }
        Action = "sts:AssumeRole"
        }
    ]
    }
    )
}

resource "aws_iam_role_policy_attachment" "attach" {
    role = aws_iam_role.todo-ec2-role.name
    policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  
}

resource "aws_iam_instance_profile" "instance_profile" {

    name = "instance_profile"
    role = aws_iam_role.todo-ec2-role.name
  
}

//aws_secret manager
resource "aws_secretsmanager_secret" "db_creds" {
  name        = "todo/db-creds"
  description = "Database credentials for todo app"
}

resource "aws_secretsmanager_secret_version" "db_creds_version" {
  secret_id     = aws_secretsmanager_secret.db_creds.id
  secret_string = jsonencode({
    host     = "database"
    port     = "3306"
    dbname   = "todo_db"
    username = var.db_username
    password = var.db_password
  })
}

//EC2_instance

resource "aws_instance" "web_instance" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    key_name = var.key_pair
    iam_instance_profile = aws_iam_instance_profile.instance_profile.name
    associate_public_ip_address = true

    tags = {
      name = "todo-ec2"
    }

}