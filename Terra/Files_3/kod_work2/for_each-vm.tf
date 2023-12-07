

resource "yandex_compute_instance" "for_each" {

depends_on = [ yandex_compute_instance.secu ]
for_each = { for v in var.each_vm: "${v.vm_name}" => v }
name = each.key

platform_id = "standard-v1"
  resources {
        cores           = each.value.cpu
        memory          = each.value.ram
        core_fraction   = each.value.frac
  }

  boot_disk {
        initialize_params {
        image_id =  "fd8g64rcu9fq5kpfqls0"
        }
  }

  network_interface {
        subnet_id = yandex_vpc_subnet.develop.id
        nat     = true
  }

  metadata = {
        ssh-keys = local.ssh
  }
}


