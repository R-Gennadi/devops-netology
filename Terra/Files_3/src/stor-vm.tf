resource "yandex_compute_instance" "stor_vm" {
  name        = "stor"
  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
    security_group_ids = [
        yandex_vpc_security_group.example.id 
        ]
    }

   dynamic "secondary_disk" {
   for_each = "${yandex_compute_disk.stor_disk.*.id}"
   content {
        disk_id = secondary_disk.value
        }
   }  
metadata = {
        ssh-keys = local.ssh
  }

}