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

variable "lamp-instance-image-id" {
  default = "fd827b91d99psvq5fjit"
}

variable "yandex_cloud_auth" {
  default = "..."
  sensitive = true
}