resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "subnet_develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}


data "yandex_compute_image" "ubuntu_image" {
  family = var.vm_web_family
}

resource "yandex_compute_instance" "platform_numb" {
  name        = local.name_1
  platform_id = var.vm_web_platform_id

  resources {
    cores         = var.vm_resources.web_resources.cores
    memory        = var.vm_resources.web_resources.memory
    core_fraction = var.vm_resources.web_resources.core_fraction
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
    subnet_id = yandex_vpc_subnet.subnet_develop.id
    nat       = true
  }
metadata = var.vm_metadata

}

data "yandex_compute_image" "ubuntu_image_db" {
  family = var.vm_db_family
}

resource "yandex_compute_instance" "platform_numb_db" {
  name        = "${ local.name_2 }"
  platform_id = var.vm_db_platform_id

  resources {
    cores         = var.vm_resources.db_resources.cores
    memory        = var.vm_resources.db_resources.memory
    core_fraction = var.vm_resources.db_resources.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image_db.id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_develop.id
    nat       = true
  }
  metadata = var.vm_metadata

}