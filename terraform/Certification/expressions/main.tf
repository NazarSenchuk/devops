terraform {}


resource "null_resource" "provision" {
   


  provisioner "local-exec" {
    command = join("\n", [
      for instance in var.instances : 
      "export ${instance.name}=${instance.name}"
    ])
}
}

variable "hello"{
    type = string
}


variable "ips"{
    type = list
}

variable "instances"{
    type = list(map(any))

} 
