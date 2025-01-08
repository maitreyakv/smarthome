variable "PI_USER_PASSWORD" {
  type      = string
  sensitive = true
}

variable "WIFI_SSID" {
  type      = string
  sensitive = true
}

variable "WIFI_PASSWORD" {
  type      = string
  sensitive = true
}

variable "RPI_IP" {
  type      = string
  sensitive = true
}

locals {
  base_img_url = join(
    "/",
    [
      "https://downloads.raspberrypi.com",
      "raspios_lite_armhf",
      "images",
      "raspios_lite_armhf-2024-11-19",
      "2024-11-19-raspios-bookworm-armhf-lite.img.xz",
    ]
  )
}

source "arm" "base_img" {
  file_checksum_type    = "sha256"
  file_checksum_url     = format("%s.%s", local.base_img_url, "sha256")
  file_target_extension = "xz"
  file_unarchive_cmd    = ["xz", "--decompress", "$ARCHIVE_PATH"]
  file_urls             = [local.base_img_url]
  image_build_method    = "reuse"
  image_chroot_env      = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]
  image_partitions {
    filesystem   = "vfat"
    mountpoint   = "/boot"
    name         = "boot"
    size         = "256M"
    start_sector = "8192"
    type         = "c"
  }
  image_partitions {
    filesystem   = "ext4"
    mountpoint   = "/"
    name         = "root"
    size         = "0"
    start_sector = "532480"
    type         = "83"
  }
  image_path                   = "raspberry-pi.img"
  image_size                   = "2G"
  image_type                   = "dos"
  qemu_binary_destination_path = "/usr/bin/qemu-arm-static"
  qemu_binary_source_path      = "/usr/bin/qemu-arm-static"
}

build {
  sources = ["source.arm.base_img"]

  provisioner "shell" {
    script = "setup.sh"
    env = {
      PI_USER_PASSWORD = var.PI_USER_PASSWORD
      WIFI_SSID        = var.WIFI_SSID
      WIFI_PASSWORD    = var.WIFI_PASSWORD
      RPI_IP           = var.RPI_IP
    }
  }
}
