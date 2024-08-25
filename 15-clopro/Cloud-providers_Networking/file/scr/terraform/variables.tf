# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = "b1g8dolaql3are1tu770"
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b1gtheioau4s71j2mu0u"
}

# Заменить на ID своего образа
# ID можно узнать с помощью команды yc compute image list
variable "centos-7-base" {
  default = "fd87bh3i9m7udk0gpn0u"
}

variable "zone" {
  default = "ru-central1-a"  
}

variable "nat-instance-name" {
  default = "nat-instance-vm1"
}

variable "nat-instance-image-id" {
  default = "fd80mrhj8fl2oe87o4e1"
}

variable "nat-instance-ip" {
  default = "192.168.10.254"
}

variable "domain" {
  default = "netology.cloud"
}

variable "public-vm-name" {
  default = "public-vm1"
}

variable "private-vm-name" {
  default = "private-vm1"
}

variable "yandex_cloud_auth" {
  default = "..."
  sensitive = true
}