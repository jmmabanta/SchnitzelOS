#!/bin/bash

# Taken from https://github.com/ublue-os/bazzite/blob/main/build_files/install-kernel-akmods

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# RPMFusion is enabled on ublueos main images
dnf5 install -y \
  fish \
  steam \
  xdg-terminal-exec \
  fuse-libs \
  nautilus-python \
  wlr-randr \
  wiremix \
  @virtualization

dnf5 install -y --setopt=install_weak_deps=False niri noctalia

dnf5 -y copr enable imput/helium
dnf5 -y install helium-bin
dnf5 -y copr disable imput/helium

dnf5 -y copr enable ilyaz/LACT
dnf5 -y install lact
dnf5 -y copr disable ilyaz/LACT

dnf5 -y copr enable lizardbyte/beta
dnf5 -y install Sunshine
dnf5 -y copr disable lizardbyte/beta

dnf5 -y copr enable scottames/ghostty
dnf5 -y install ghostty
dnf5 -y copr disable scottames/ghostty

dnf5 remove -y firefox showtime firefox-langpacks

