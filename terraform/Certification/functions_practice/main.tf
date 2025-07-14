variable "paths" {
  type    = list(string)
  default = ["hello", "world"]
}

locals {
  paths = [{
    name = "root"
    path = "${path.root}/"
    }, {
    name = "module"
    path = "${path.module}/"
    },
    { name = "temp"
    }
  ]
}
