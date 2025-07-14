data "aws_key_pair" "linux" {
  key_name = var.key_name
}

data "cloudinit_config" "server_config" {
  gzip          = false
  base64_encode = true
  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = file("${path.module}/cloud_init/cloud_init.yaml")
  }
}


resource "aws_instance" "controlplane" {
  count = var.count_controlplane

  #Distribution  controlplane nodes beetwen  subnets 
  subnet_id       = var.subnets_for_controlplanes[count.index % length(var.subnets_for_controlplanes)]
  ami             = var.ami_id
  instance_type   = var.instance_type_for_controlplane
  key_name        = data.aws_key_pair.linux.key_name
  security_groups = [var.default_security_group_id]


  tags = {
    Name = "control-plane${count.index}"
  }

  user_data = data.cloudinit_config.server_config.rendered
}
