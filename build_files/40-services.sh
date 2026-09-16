#!/bin/bash

set -ouex pipefail

# Setup Homebrew
systemctl preset brew-setup.service
systemctl preset brew-update.timer
systemctl preset brew-upgrade.timer

# Setup Bazaar
systemctl enable flatpak-preinstall.service

# Setup NVIDIA driver flatpak sync
systemctl enable sync-nvidia-flatpak.service

systemctl enable lactd
systemctl enable libvirtd
