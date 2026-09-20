#!/bin/bash

# Taken from https://github.com/ublue-os/bazzite/blob/main/build_files/install-kernel-akmods

set -ouex pipefail

# Add Flathub to the image for eventual application
mkdir -p /etc/flatpak/remotes.d/
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

# Setup Negativo17 multimedia repo for codecs
# (should be me 'complete' than RPMFusion I think)
if ! grep -q fedora-multimedia <(dnf5 repolist); then
  # Enable or Install Repofile
  dnf5 config-manager setopt fedora-multimedia.enabled=1 ||
    dnf5 config-manager addrepo --from-repofile="https://negativo17.org/repos/fedora-multimedia.repo"
fi
# Set higher priority
dnf5 config-manager setopt fedora-multimedia.priority=90

# Replace these with better ones from Negativo17
OVERRIDES=(
  intel-gmmlib
  intel-mediasdk
  intel-vpl-gpu-rt
  libheif
  libva
  libva-intel-media-driver
  mesa-dri-drivers
  mesa-filesystem
  mesa-libEGL
  mesa-libGL
  mesa-libgbm
  mesa-vulkan-drivers
)
dnf5 distro-sync --skip-unavailable -y --repo='fedora-multimedia' "${OVERRIDES[@]}"
dnf5 versionlock add "${OVERRIDES[@]}"

NEGATIVO_PACKAGES=(
  ffmpeg
  intel-vaapi-driver
  libavcodec
  libfdk-aac
  libva-utils
  pipewire-libs-extra
  steam
)

FEDORA_PACKAGES=(
  @virtualization
  adw-gtk3-theme
  btop
  distrobox
  fastfetch
  ffmpegthumbnailer
  fish
  flatpak-spawn
  fuse{,-libs}
  fzf
  gamemode
  google-noto-sans-balinese-fonts
  google-noto-sans-cham-fonts
  google-noto-sans-cjk-fonts
  google-noto-sans-javanese-fonts
  google-noto-sans-linear-a-fonts
  google-noto-sans-linear-b-fonts
  google-noto-sans-sundanese-fonts
  grub2-tools-extra
  gvfs{,-fuse,-nfs}
  libayatana-appindicator-gtk3
  lshw
  nautilus-python
  nvtop
  vim
  wiremix
  wlr-randr
  xdg-terminal-exec
)

PACKAGES=( "${FEDORA_PACKAGES[@]}" "${NEGATIVO_PACKAGES[@]}" )
dnf5 install -y --enablerepo='fedora-multimedia' "${PACKAGES[@]}"
# No need for the extra deps these bring in
dnf5 install -y --setopt=install_weak_deps=False niri noctalia
# Fix google cjk fonts
ln -s "/usr/share/fonts/google-noto-sans-cjk-fonts" "/usr/share/fonts/noto-cjk"

# Install dmemcg-booster for low VRAM cards
# Recently, NVIDIA supposedly added cgroups to their driver so I want to test it
dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras}
dnf5 -y config-manager setopt "*terra*".priority=1 "*terra*".exclude="nerd-fonts scx-tools scx-scheds python3-protobuf zlib-devel uupd"
dnf5 -y install dmemcg-booster
dnf5 -y config-manager setopt "terra".enabled=0
dnf5 -y config-manager setopt "terra-extras".enabled=0

# Helium > Firefox
dnf5 -y copr enable imput/helium
dnf5 -y install helium-bin
dnf5 -y copr disable imput/helium

# LACT for GPU overclock
dnf5 -y copr enable ilyaz/LACT
dnf5 -y install lact
dnf5 -y copr disable ilyaz/LACT

# Sunshine for local game streaming
dnf5 -y copr enable lizardbyte/stable
dnf5 -y install Sunshine
dnf5 -y copr disable lizardbyte/stable

# Ghostty is fancier ptyxis + can share config with macOS
dnf5 -y copr enable scottames/ghostty
dnf5 -y install ghostty
dnf5 -y copr disable scottames/ghostty

# uupd handles automatic image + flatpak + homebrew updates
dnf5 -y copr enable ublue-os/packages
dnf5 -y install uupd
dnf5 -y copr disable ublue-os/packages

# Install mangohud from bazzite-multilib as the fedora version is buggy
dnf5 -y copr enable ublue-os/bazzite-multilib
dnf5 -y install mangohud.x86_64 mangohud.i686
dnf5 -y copr disable ublue-os/bazzite-multilib

REMOVE=(
  fedora-third-party
  firefox
  firefox-langpacks
  gnome-classic-session
  gnome-extensions-app
  gnome-software
  gnome-software-rpm-ostree
  gnome-tour
  ptyxis
  totem-video-thumbnailer
  yelp
)
dnf5 remove -y "${REMOVE[@]}"

# Patch grub2-mkconfig so it works with regenerate-grub
# From https://github.com/ublue-os/bazzite/blob/6c108d6cb377d78c5e6484787180e7a741b58b84/Containerfile#L462
# which might have something to do with https://github.com/ublue-os/bluefin/issues/2582#issuecomment-3476538251
sed -i "s|grub_probe\} --target=device /\`|grub_probe} --target=device /sysroot\`|g" /usr/bin/grub2-mkconfig
