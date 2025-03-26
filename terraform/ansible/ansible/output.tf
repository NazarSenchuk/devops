output "instances_ip" {  
    value = aws_instance.ansible.public_ip
    description = "Public IP address of the Ansible instance"
}