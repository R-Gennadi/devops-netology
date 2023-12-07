
output "ubuntu_image" {
  value = yandex_compute_instance.platform_numb.network_interface.0.nat_ip_address
description = "vm external ip ubuntu_image"
} 

output "ubuntu_image_db" {
  value = yandex_compute_instance.platform_numb_db.network_interface.0.nat_ip_address
description = "vm external ip ubuntu_image_db"
}