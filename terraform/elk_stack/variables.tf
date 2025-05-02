variable "path_to_certs" {
    default = "/home/nazar/devops/kubernetes/elk/eck/certificates"
    description = "path  to directory that contain certificates"
  
}
variable "username"{

    default ="elastic"
    description = "user username"

}
variable "password" {

    description = "password for user"
}


variable "filebeat_log_paths" {
  description = "List of log paths for Filebeat to monitor"
  type        = list(string)
  default     = [
    "/var/log/*.log",
    "/var/log/nginx-containers/*.log"
  ]
}

variable "filebeat_index_name" {
    default = "filebeat-%%{+yyyy.MM.dd}"
    description = "index_name"


}
variable "filebeat_path_certs" {
    default = "/usr/share/filebeat/config/elasticsearch-certs/ca.crt"
    description = "Path in filebeat container that point to certs"
    
  
}