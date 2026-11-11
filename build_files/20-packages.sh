#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# ========= PACKAGES =========

NEGATIVO_OVERRIDES=(
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
  openh264
)

NEGATIVO_PACKAGES=(
  ffmpeg
  intel-vaapi-driver
  libavcodec
  libfdk-aac
  libva-utils
  pipewire-libs-extra
)

FEDORA_PACKAGES=(
  cockpit
  cockpit-files
  cockpit-machines
  cockpit-podman
  distrobox
  fish
  flatpak-spawn
  google-noto-sans-cjk-fonts
  kate
  libayatana-appindicator-gtk3
  lshw
  nvtop
  plasma-firewall
  sbsigntools
  twitter-twemoji-fonts
)

DOCKER_PACKAGES=(
  containerd.io
  docker-buildx-plugin
  docker-ce
  docker-ce-cli
  docker-compose-plugin
)

TERRA_PACKAGES=(
  bpfrag
  bpftune
  dmemcg-booster
  noctalia-greeter
  plasma-foreground-booster-dmemcg
  steam
  terra-mangohud
  uupd
)

REMOVE=(
  akonadi-server{,-mysql}
  fedora-bookmarks
  fedora-chromium-config{,-kde}
  fedora-third-party
  firefox
  firefox-langpacks
  gamemode
  kcharselect
  khelpcenter
  kwrite
  plasma-discover-rpm-ostree
  plasma-login-manager
  toolbox
  xwaylandvideobridge
)

# ========= SETUP REPOS =========

# Add Flathub to the image for eventual application
mkdir -p /etc/flatpak/remotes.d/
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

# Setup Negativo17 multimedia repo for codecs
# (should be more 'complete' than RPMFusion I think)
if ! grep -q fedora-multimedia <(dnf5 repolist); then
  dnf5 config-manager enable fedora-multimedia ||
    dnf5 config-manager addrepo --from-repofile="https://negativo17.org/repos/fedora-multimedia.repo"
fi
dnf5 config-manager setopt fedora-multimedia.priority=90

# Docker
dnf5 config-manager addrepo --from-repofile="https://download.docker.com/linux/fedora/docker-ce.repo"
dnf5 config-manager disable docker-ce-stable

# Terra
dnf5 install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release{,-extras}
dnf5 config-manager setopt "*terra*".priority=1
dnf5 config-manager disable terra terra-extras

dnf5 makecache --refresh

# ========= INSTALL PACKAGES =========

dnf5 distro-sync --skip-unavailable --allowerasing -y --repo='fedora-multimedia' "${NEGATIVO_OVERRIDES[@]}"
dnf5 versionlock add "${NEGATIVO_OVERRIDES[@]}"

PACKAGES=( "${FEDORA_PACKAGES[@]}" "${NEGATIVO_PACKAGES[@]}" )
dnf5 install -y --enablerepo='fedora-multimedia' "${PACKAGES[@]}"

dnf5 install -y --from-repo="docker-ce-stable" "${DOCKER_PACKAGES[@]}"
# Load iptable_nat module for docker-in-docker.
# See:
#   - https://github.com/ublue-os/bluefin/issues/2365
#   - https://github.com/devcontainers/features/issues/1235
mkdir -p /etc/modules-load.d && cat >>/etc/modules-load.d/ip_tables.conf <<EOF
iptable_nat
EOF

dnf5 install -y \
  --from-repo="terra,terra-extras" \
  --exclude='mangohud*,gpu-screen-recorder' \
  "${TERRA_PACKAGES[@]}"

dnf5 remove -y "${REMOVE[@]}"

# Patch grub2-mkconfig so it works with regenerate-grub
# From https://github.com/ublue-os/bazzite/blob/6c108d6cb377d78c5e6484787180e7a741b58b84/Containerfile#L462
# which might have something to do with https://github.com/ublue-os/bluefin/issues/2582#issuecomment-3476538251
sed -i "s|grub_probe\} --target=device /\`|grub_probe} --target=device /sysroot\`|g" /usr/bin/grub2-mkconfig

echo "::endgroup::"
