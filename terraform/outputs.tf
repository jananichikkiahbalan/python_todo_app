output "ec2_public_ip" {
    value = aws_instance.web_instance.public_ip
    description = "the public IP of EC2 instance"
  
}

output "ec2_instance_id" {

    value = aws_instance.web_instance.id
    description = "instance ID"
  
}