#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Add Flathub to the image for eventual application
mkdir -p /etc/flatpak/remotes.d/
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

# Setup Negativo17 multimedia repo for codecs
# (should be more 'complete' than RPMFusion I think)
if ! grep -q fedora-multimedia <(dnf5 repolist); then
  # Enable or Install Repofile
  dnf5 config-manager enable fedora-multimedia ||
    dnf5 config-manager addrepo --from-repofile="https://negativo17.org/repos/fedora-multimedia.repo"
fi
# Set higher priority
dnf5 config-manager setopt fedora-multimedia.priority=90

# Replace these with better ones from Negativo17
OVERRIDES=(
  intel-gmmlib
  intel-mediasdk
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

dnf5 distro-sync --skip-unavailable --allowerasing -y --repo='fedora-multimedia' "${OVERRIDES[@]}"
dnf5 versionlock add "${OVERRIDES[@]}"

NEGATIVO_PACKAGES=(
  ffmpeg
  intel-vaapi-driver
  libavcodec
  libfdk-aac
  libva-utils
  pipewire-libs-extra
)

FEDORA_PACKAGES=(
  @virtualization
  adw-gtk3-theme
  cava
  cockpit
  cockpit-files
  cockpit-machines
  cockpit-podman
  distrobox
  ffmpegthumbnailer
  fish
  flatpak-spawn
  foot
  fuse{,-libs}
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
  nvtop
  podman-compose
  sbsigntools
  wlr-randr
  xdg-terminal-exec
)

PACKAGES=( "${FEDORA_PACKAGES[@]}" "${NEGATIVO_PACKAGES[@]}" )
dnf5 install -y \
  --exclude=cockpit-ostree \
  --enablerepo='fedora-multimedia' \
  "${PACKAGES[@]}"

DOCKER_PACKAGES=(
  containerd.io
  docker-buildx-plugin
  docker-ce
  docker-ce-cli
  docker-compose-plugin
)
dnf5 config-manager addrepo --from-repofile="https://download.docker.com/linux/fedora/docker-ce.repo"
dnf5 install -y --from-repo="docker-ce-stable" "${DOCKER_PACKAGES[@]}"
dnf5 config-manager disable docker-ce-stable
# Load iptable_nat module for docker-in-docker.
# See:
#   - https://github.com/ublue-os/bluefin/issues/2365
#   - https://github.com/devcontainers/features/issues/1235
mkdir -p /etc/modules-load.d && cat >>/etc/modules-load.d/ip_tables.conf <<EOF
iptable_nat
EOF

# View and manage docker/podman composes (MC Server) in cockpit
curl -o /tmp/cockpit-compose-latest.rpm \
  -L https://github.com/RXTX4816/cockpit-compose/releases/latest/download/cockpit-compose-latest.rpm
dnf5 install -y --nogpgcheck /tmp/cockpit-compose-latest.rpm

TERRA_PACKAGES=(
  dmemcg-booster
  ghostty
  noctalia-nightly
  steam
  terra-mangohud
  umbriel-nightly
)
dnf5 install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras}
dnf5 config-manager setopt "*terra*".priority=1
dnf5 install -y --exclude='mangohud*,gpu-screen-recorder' "${TERRA_PACKAGES[@]}"
# VRAM Management for non-KDE DEs
dnf5 swap -y --repo terra-extras uresourced uresourced-dmemcg
dnf5 config-manager disable terra terra-extras

COPR_PREFIX="copr:copr.fedorainfracloud.org"

# uupd handles automatic image + flatpak + homebrew updates
dnf5 copr -y enable ublue-os/packages
dnf5 install -y --from-repo="${COPR_PREFIX}:ublue-os:packages" uupd
dnf5 copr -y disable ublue-os/packages

# for gamestreaming
dnf5 copr -y enable lizardbyte/stable
dnf5 install -y --from-repo="${COPR_PREFIX}:lizardbyte:stable" Sunshine
dnf5 copr -y disable lizardbyte/stable

dnf5 copr -y enable bieszczaders/kernel-cachyos-addons
dnf5 install -y --from-repo="${COPR_PREFIX}:bieszczaders:kernel-cachyos-addons" \
  scx-scheds scx-tools
dnf5 copr -y disable bieszczaders/kernel-cachyos-addons

REMOVE=(
  fedora-third-party
  firefox
  firefox-langpacks
  gnome-classic-session
  gnome-extensions-app
  gnome-shell-extension-apps-menu
  gnome-shell-extension-background-logo
  gnome-shell-extension-launch-new-instance
  gnome-shell-extension-places-menu
  gnome-shell-extension-window-list
  gnome-software
  gnome-software-rpm-ostree
  gnome-system-monitor
  gnome-tour
  ptyxis
  totem-video-thumbnailer
  yelp
)
dnf5 remove -y "${REMOVE[@]}"

# https://www.phoronix.com/review/fedora-pantherlake-thermald-tuned
dnf5 swap -y tuned-ppd power-profiles-daemon
# https://my.devsuite.app/@chergert/117446918437204806
dnf5 remove -y intel-lpmd

# Patch grub2-mkconfig so it works with regenerate-grub
# From https://github.com/ublue-os/bazzite/blob/6c108d6cb377d78c5e6484787180e7a741b58b84/Containerfile#L462
# which might have something to do with https://github.com/ublue-os/bluefin/issues/2582#issuecomment-3476538251
sed -i "s|grub_probe\} --target=device /\`|grub_probe} --target=device /sysroot\`|g" /usr/bin/grub2-mkconfig

echo "::endgroup::"
