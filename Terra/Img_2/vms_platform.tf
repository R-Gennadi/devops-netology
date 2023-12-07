###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "family compute_image"
}  

variable "names" {
  type        = string
  default     = "netology-develop-platform"
 description = "name compute_instance"
}

variable "vm_web" {
  type        = string
  default     = "web"
 description = "name compute_instance1"
}

variable "vm_web_platform_id" {
  type        = string
  default     = "standard-v2"
  description = "platform compute_instance"
}

variable "vm_db_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "family compute_image"
}  

variable "vm_db" {
  type        = string
  default     = "db"
 description = "name compute_instance2"
}

variable "vm_db_platform_id" {
  type        = string
  default     = "standard-v2"
  description = "platform compute_instance"
}

variable "vm_resources" {
  description = "resources all"
  type = map(map(number))
  default = {
     web_resources = {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
    db_resources = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  }
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}


###ssh vars

variable "vm_metadata" {
  description = "metadata all"
  type        = map(string)
  default     = {
    serial-port-enable = 1
    ssh-keys  = "ubuntu:ssh-ed25519 AAAA*************************************************** ubuntu@ubuntu2004"
  }
  
}
