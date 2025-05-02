output "instances_ip" {  
    value = aws_instance.ansible[0].public_ip
    description = "Public IP address of the Ansible instance"
}