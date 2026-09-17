#!/bin/bash

set -ouex pipefail

# Setup Homebrew
systemctl preset brew-setup.service
systemctl preset brew-update.timer
systemctl preset brew-upgrade.timer

# Setup Bazaar
systemctl enable flatpak-preinstall.service
systemctl --global enable bazaar-daemon.service

# Setup NVIDIA driver flatpak sync
systemctl enable sync-nvidia-flatpak.service

# Use ublue-os/uupd for automatic updates, not rpm-ostree
systemctl enable uupd.timer
systemctl disable rpm-ostreed-automatic.timer

# dmemcg booster
systemctl enable dmemcg-booster-system.service
systemctl --global enable dmemcg-booster-user.service

# libvirt
systemctl enable libvirtd.service
systemctl enable libvirt-workarounds.service

systemctl enable lactd.service
systemctl enable podman.socket
