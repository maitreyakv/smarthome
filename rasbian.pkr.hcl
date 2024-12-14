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

  # Basic dev tools
  provisioner "shell" {
    inline = ["apt-get install -y vim tree tmux btop"]
  }

  # SSH configuration
  provisioner "shell" {
    inline = ["touch /boot/ssh"]
  }
  
  # Sets pi user password
  provisioner "shell" {
    inline = ["echo \"pi:${var.PI_USER_PASSWORD}\" | chpasswd"]
  }

  # Wi-Fi configuration
  provisioner "shell" {
    inline = [
      "raspi-config nonint do_wifi_country US",
      "nmcli --offline connection add type wifi ssid \"${var.WIFI_SSID}\" ifname \"wlan0\" con-name \"${var.WIFI_SSID}\" wifi-sec.psk \"${var.WIFI_PASSWORD}\" wifi-sec.key-mgmt wpa-psk wifi-sec.auth-alg open > /etc/NetworkManager/system-connections/maitreyakv-wifi.nmconnection",
      "chmod 600 /etc/NetworkManager/system-connections/maitreyakv-wifi.nmconnection"
    ]
  }

}
