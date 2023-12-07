locals {
  ssh = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
}

