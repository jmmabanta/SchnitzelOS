#!/bin/bash

set -ouex pipefail

# Setup Homebrew
systemctl preset brew-setup.service
# Add linuxbrew to the list of paths usable by `sudo`
# not a sudoers.d override because we want to get updates from upstream and not break everything
sed -Ei "s/secure_path = (.*)/secure_path = \1:\/home\/linuxbrew\/.linuxbrew\/bin/" /etc/sudoers

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
systemctl --global enable niri-focused-booster.service

# libvirt
systemctl enable libvirtd.service
systemctl enable libvirt-workarounds.service

# ghostty
systemctl --global enable app-com.mitchellh.ghostty.service

systemctl enable lactd.service
systemctl enable podman.socket
