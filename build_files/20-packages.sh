#!/bin/bash

# Taken from https://github.com/ublue-os/bazzite/blob/main/build_files/install-kernel-akmods

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# gnome-software -> replaced by Bazaar
# firefox -> use built-in Helium browser instead or install firefox flatpak
dnf5 remove -y \
  gnome-software \
  firefox \
  firefox-langpacks \
  mangohud

# RPMFusion is enabled on ublueos main images
dnf5 install -y \
  fish \
  steam \
  xdg-terminal-exec \
  fuse-libs \
  nautilus-python \
  wlr-randr \
  wiremix \
  gamemode \
  @virtualization

dnf5 install -y --setopt=install_weak_deps=False niri noctalia

# Install mangohud from terra as fedora's version is buggy
dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras}
dnf5 -y config-manager setopt "*terra*".priority=1 "*terra*".exclude="nerd-fonts scx-tools scx-scheds python3-protobuf zlib-devel uupd"
dnf5 --enable-repo=terra --enable-repo=terra-extras -y install terra-mangohud.x86_64 terra-mangohud.i686
dnf5 -y config-manager setopt "terra".enabled=0
dnf5 -y config-manager setopt "terra-extras".enabled=0

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

dnf5 -y copr enable ublue-os/packages
dnf5 -y install uupd
dnf5 -y copr disable ublue-os/packages

# Patch grub2-mkconfig so it works with regenerate-grub
# From https://github.com/ublue-os/bazzite/blob/6c108d6cb377d78c5e6484787180e7a741b58b84/Containerfile#L462
# which might have something to do with https://github.com/ublue-os/bluefin/issues/2582#issuecomment-3476538251
sed -i "s|grub_probe\} --target=device /\`|grub_probe} --target=device /sysroot\`|g" /usr/bin/grub2-mkconfig
