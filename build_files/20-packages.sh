#!/bin/bash

# Taken from https://github.com/ublue-os/bazzite/blob/main/build_files/install-kernel-akmods

set -ouex pipefail

# RPMFusion is enabled on ublueos main images
dnf5 install -y \
  fish \
  foot \
  steam \
  xdg-terminal-exec \
  fuse-libs \
  nautilus-python \
  wlr-randr \
  wiremix \
  gamemode \
  @virtualization

dnf5 install -y --setopt=install_weak_deps=False niri noctalia

dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras}
dnf5 -y config-manager setopt "*terra*".priority=1 "*terra*".exclude="nerd-fonts scx-tools scx-scheds python3-protobuf zlib-devel uupd"
# Install dmemcg-booster for low VRAM cards
# Recently, NVIDIA supposedly added cgroups to their driver so I want to test it
dnf5 -y install dmemcg-booster
dnf5 -y config-manager setopt "terra".enabled=0
dnf5 -y config-manager setopt "terra-extras".enabled=0

dnf5 -y copr enable imput/helium
dnf5 -y install helium-bin
dnf5 -y copr disable imput/helium

dnf5 -y copr enable ilyaz/LACT
dnf5 -y install lact
dnf5 -y copr disable ilyaz/LACT

dnf5 -y copr enable lizardbyte/stable
dnf5 -y install Sunshine
dnf5 -y copr disable lizardbyte/stable

dnf5 -y copr enable scottames/ghostty
dnf5 -y install ghostty
dnf5 -y copr disable scottames/ghostty

dnf5 -y copr enable ublue-os/packages
dnf5 -y install uupd
dnf5 -y copr disable ublue-os/packages

# Install mangohud from bazzite-multilib as the fedora version is buggy
dnf5 -y copr enable ublue-os/bazzite-multilib
dnf5 -y install mangohud.x86_64 mangohud.i686
dnf5 -y copr disable ublue-os/bazzite-multilib

# gnome-software -> replaced by Bazaar
# firefox -> use built-in Helium browser instead or install firefox flatpak
# ptyxis -> ghostty
dnf5 remove -y \
  gnome-software \
  firefox \
  firefox-langpacks \
  ptyxis \
  gnome-classic-session \
  gnome-extensions-app \
  gnome-tour \
  yelp

# Patch grub2-mkconfig so it works with regenerate-grub
# From https://github.com/ublue-os/bazzite/blob/6c108d6cb377d78c5e6484787180e7a741b58b84/Containerfile#L462
# which might have something to do with https://github.com/ublue-os/bluefin/issues/2582#issuecomment-3476538251
sed -i "s|grub_probe\} --target=device /\`|grub_probe} --target=device /sysroot\`|g" /usr/bin/grub2-mkconfig
