resource "yandex_compute_disk" "stor_disk" {
  name  = "disk-${count.index + 1}"
  type = "network-hdd"
  size  = 1
  count   = 3
}