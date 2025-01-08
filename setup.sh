#!/bin/bash

# Configure script execution
set -euo pipefail

# Install software from package manager
apt-get update
apt-get install -y vim tree tmux btop
apt-get clean

# Enable SSH
touch /boot/ssh

# Create password for SSH
echo pi:"${PI_USER_PASSWORD}" | chpasswd

# WIFI configuration
raspi-config nonint do_wifi_country US
NM_CONNETION_NAME=${WIFI_SSID// /_}
NM_CONNECTION_FILE="/etc/NetworkManager/system-connections/${NM_CONNETION_NAME}.nmconnection"
nmcli --offline connection add \
  type "wifi" \
  ssid "${WIFI_SSID}" \
  ifname "wlan0" \
  con-name "${NM_CONNETION_NAME}" \
  wifi-sec.psk "${WIFI_PASSWORD}" \
  wifi-sec.key-mgmt "wpa-psk" \
  wifi-sec.auth-alg "open" >"${NM_CONNECTION_FILE}"
chmod 600 "${NM_CONNECTION_FILE}"

# Kubernetes setup
sed -r "$ s/\n$//" /boot/cmdline.txt | xargs -I{} echo {} "cgroup_memory=1 cgroup_enable=memory" >cmdline.txt
mv cmdline.txt /boot/cmdline.txt
curl -sfL https://get.k3s.io | sh -
sed -i -e "s/server/server --node-ip=${RPI_IP}/" /etc/systemd/system/k3s.service
