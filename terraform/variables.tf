variable "aws_region" {
    type = string
    default = "ap-south-1"
    description = "Region to deploy in"
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
    description = "CIDR block for the VPC"
  
}

variable "subnet_cidr" {
    type = string
    default = "10.0.1.0/24"
    description = "CIDR block for the public subnet"
  
}

variable "instance_type" {
    type = string
    default = "t3.micro"
    description = "EC2 instance type"
  
}
variable "ami_id" {
    type = string
    default = "ami-0f58b397bc5c1f2e8"
    description = "AMI ID for ap-south-1"
  
}

variable "key_pair" {
    type = string
    description = "AWS key pair name for SSH"

}

variable "db_username" {
    type = string
    description = "Database username"
    sensitive = true
}

variable "db_password" {
    type = string
    description = "Database password"
    sensitive = true
  
}