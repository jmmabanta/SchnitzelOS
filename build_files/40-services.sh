#!/bin/bash

set -ouex pipefail

systemctl preset brew-setup.service
# Add linuxbrew to the list of paths usable by `sudo`
# not a sudoers.d override because we want to get updates from upstream and not break everything
sed -Ei "s/secure_path = (.*)/secure_path = \1:\/home\/linuxbrew\/.linuxbrew\/bin/" /etc/sudoers

systemctl enable flatpak-preinstall.service
systemctl --global enable bazaar-daemon.service

systemctl enable sync-nvidia-flatpak.service

# Use ublue-os/uupd for automatic updates, not rpm-ostree
systemctl enable uupd.timer
systemctl disable rpm-ostreed-automatic.timer

systemctl enable dmemcg-booster-system.service
systemctl --global enable dmemcg-booster-user.service

systemctl enable libvirtd.service
systemctl enable libvirt-workarounds.service

systemctl enable podman.socket

# Disable unneeded services that can slowdown boot
# https://github.com/ublue-os/bazzite/commit/d6334b34d3a75bd70082581d1337cbec849e695c
systemctl mask iscsi
# https://github.com/ublue-os/bazzite/pull/4279
systemctl mask systemd-remount-fs.service
# https://github.com/ublue-os/bazzite/pull/5449
systemctl mask fedora-atomic-desktop-appstream-cache-refresh
