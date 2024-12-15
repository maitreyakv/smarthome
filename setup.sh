#!/bin/bash

set -euo pipefail

apt-get install -y vim tree tmux btop

touch /boot/ssh

echo pi:"${PI_USER_PASSWORD}" | chpasswd

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
