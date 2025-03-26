data "aws_ami" "ubuntu" {
    most_recent = true


}
data "aws_key_pair" "linux"{
    key_name ="linux"

}

resource "aws_security_group" "allow_all_trafic" {

 name        = "allow_all_trafic"

 description ="Allows all trafic"

 vpc_id      = var.vpc_id



ingress {

   description = "allow all"

   from_port   = 0

   to_port     = 0 

   protocol    = "-1"

   cidr_blocks = ["0.0.0.0/0"]

 }



egress {

   from_port   = 0

   to_port     = 0

   protocol    = "-1"

   cidr_blocks = ["0.0.0.0/0"]

 }

}

resource "aws_instance" "ansible" {
    subnet_id = var.ansible_subnet.id
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"
    key_name = data.aws_key_pair.linux.key_name	
    
    security_groups=[aws_security_group.allow_all_trafic.id]
    tags = {
        Name = "ansible"

    }
    user_data = filebase64("${path.module}/ansible.sh")






}
