## Задача 1:
>Создайте собственный образ любой операционной системы (например, debian-11) с помощью Packer версии 1.7.0 
Чтобы получить зачёт, вам нужно предоставить скриншот страницы с созданным образом из личного кабинета YandexCloud.
 
![img.png](/img/img.png)


## Задача 2:
> 2.1. Создайте вашу первую виртуальную машину в YandexCloud с помощью web-интерфейса YandexCloud.

<image src="/img/img_1.png" alt="ris2">

> 2.2. *(Необязательное задание)
Создайте вашу первую виртуальную машину в YandexCloud с помощью Terraform (вместо использования веб-интерфейса YandexCloud). Используйте Terraform-код в директории (src/terraform).
Чтобы получить зачёт, вам нужно предоставить вывод команды terraform apply и страницы свойств, созданной ВМ из личного кабинета YandexCloud. 

<details>
<summary>вывод команды terraform apply</summary>

ubuntu@ubuntu2004:~/cloud/terra/1$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

    # yandex_compute_instance.node01 will be created
  + resource "yandex_compute_instance" "node01" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + gpu_cluster_id            = (known after apply)
      + hostname                  = "node01.netology.cloud"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                centos:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJMeF68bjUnd9dmkuwV3yB7iIIBQddxXzwbMkAMEk8feFJAdSCLvUBr7n4tpmfNFbCVeXmLkSUzPx8mmVOhnkQWlPlYbAsMNB9sa1W4ME39OxXZ+GrCMt2ew3CdwtQhZESXLeSbKZx0GD6N0kSdBA/42FzZmbjX9rbagzFm2ywWAv8pKQXcuFLT5QYzsew9+Du46C8NZowJPCFyzgezhigdfCdwpGuQsOn3eFvvrMDrRTOKO1ifk11ZNeWWLBGgFGFXUcU4MseMYzwUmXsI5PQ5Bk2UZhUzctSHRHsysADh+T8NiAXVAvi2RhuGen3SaXble+iRdfD2NIWi4vL7AnFV7FxGY4BsP+2XOu82jgmpPKRhAGSub7LNTJOkQWo9zJlP+yWgvi3Y66OUOxpjS7t12EvyUPjb/nstCDeJWzu3/9XgIKpU3eW1Hm7SZF75rDUmirjwQ5rNAi58iBpldP/Mq4v595NpeQRqVhZiWrP3Kl3N7Hq2bjMANJ2spZzB1k= ubuntu@ubuntu2004
            EOT
        }
      + name                      = "node01"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8cibvfnkuplgsdo435"
              + name        = "root-node01"
              + size        = 50
              + snapshot_id = (known after apply)
              + type        = "network-nvme"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 8
          + memory        = 8
        }
    }

  # yandex_vpc_network.default will be created
  + resource "yandex_vpc_network" "default" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "net"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.default will be created
  + resource "yandex_vpc_subnet" "default" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "my-sbnt-a"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.101.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address_node01_yandex_cloud = (known after apply)
  + internal_ip_address_node01_yandex_cloud = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

yandex_vpc_network.default: Creating...
yandex_vpc_network.default: Creation complete after 3s [id=enpdj5vtmg9ssdmp8uj8]
yandex_vpc_subnet.default: Creating...
yandex_vpc_subnet.default: Creation complete after 2s [id=e9btjcf336otdgjk2roq]
yandex_compute_instance.node01: Creating...
yandex_compute_instance.node01: Still creating... [10s elapsed]
yandex_compute_instance.node01: Still creating... [20s elapsed]
yandex_compute_instance.node01: Still creating... [30s elapsed]
yandex_compute_instance.node01: Still creating... [40s elapsed]
yandex_compute_instance.node01: Still creating... [50s elapsed]
yandex_compute_instance.node01: Still creating... [1m0s elapsed]
yandex_compute_instance.node01: Still creating... [1m10s elapsed]
yandex_compute_instance.node01: Still creating... [1m20s elapsed]
yandex_compute_instance.node01: Creation complete after 1m26s [id=fhmt4qjjjc8qf5jgure3]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_node01_yandex_cloud = "158.160.62.32"
internal_ip_address_node01_yandex_cloud = "192.168.101.24"
</details> 

 ![img_2.png](/img/img_2.png)
          
 
## Задача 3:
* С помощью Ansible и Docker Compose разверните на виртуальной машине из предыдущего задания систему мониторинга на основе Prometheus/Grafana. 
Используйте Ansible-код в директории (src/ansible).
Чтобы получить зачёт, вам нужно предоставить вывод команды "docker ps" , все контейнеры, описанные в docker-compose, должны быть в статусе "Up".

        [debian@node02 ~]$ sudo docker ps
        CONTAINER ID   IMAGE                              COMMAND                  CREATED         STATUS                   PORTS                                                                              NAMES
        ae448d009ee2   prom/pushgateway:v1.2.0            "/bin/pushgateway"       7 minutes ago   Up 7 minutes             9091/tcp                                                                           pushgateway
        03694477cb5d   grafana/grafana:7.4.2              "/run.sh"                7 minutes ago   Up 7 minutes             3000/tcp                                                                           grafana
        298303eb4f76   prom/prometheus:v2.17.1            "/bin/prometheus --c…"   7 minutes ago   Up 7 minutes             9090/tcp                                                                           prometheus
        75cec169d566   prom/node-exporter:v0.18.1         "/bin/node_exporter …"   7 minutes ago   Up 7 minutes             9100/tcp                                                                           nodeexporter
        0ddf653d46ef   stefanprodan/caddy                 "/sbin/tini -- caddy…"   7 minutes ago   Up 7 minutes             0.0.0.0:3000->3000/tcp, 0.0.0.0:9090-9091->9090-9091/tcp, 0.0.0.0:9093->9093/tcp   caddy
        b9a1d7c1da6b   prom/alertmanager:v0.20.0          "/bin/alertmanager -…"   7 minutes ago   Up 7 minutes             9093/tcp                                                                           alertmanager
        f02332492fa3   gcr.io/cadvisor/cadvisor:v0.47.0   "/usr/bin/cadvisor -…"   7 minutes ago   Up 7 minutes (healthy)   8080/tcp                                                                           cadvisor

  

## Задача 4:
* Откройте веб-браузер, зайдите на страницу http://<внешний_ip_адрес_вашей_ВМ>:3000.
Используйте для авторизации логин и пароль из .env-file.
Изучите доступный интерфейс, найдите в интерфейсе автоматически созданные docker-compose-панели с графиками(dashboards).
Подождите 5-10 минут, чтобы система мониторинга успела накопить данные.
Чтобы получить зачёт, предоставьте:
скриншот работающего веб-интерфейса Grafana с текущими метриками, как на примере

<image src="/img/img_3.png" alt="ris3">


