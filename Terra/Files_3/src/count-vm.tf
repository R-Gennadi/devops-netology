data "yandex_compute_image" "ubuntu_image" {
  family = var.image_vm
  }

resource "yandex_compute_instance" "web_s" {
  name        = "web-${count.index+1}"
  platform_id = "standard-v1"

count = 2

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
        yandex_vpc_security_group.example.id ]
  }
metadata = {
        ssh-keys = local.ssh
  }

}