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

# Install latest MangoHud binary from GitHub
# The one currently packaged in fedora is bugged
MANGOHUD_URL="$(
  curl -fsSL https://api.github.com/repos/flightlessmango/MangoHud/releases/latest |
  jq -r '.assets[]
    | select(.browser_download_url | contains("r0"))
    | select(.browser_download_url | endswith(".tar.gz"))
    | .browser_download_url' |
  head -n1
)"
MANGOHUD_TMP_DIR=$(mktemp -d)
trap 'rm -rf "$MANGOHUD_TMP_DIR"' EXIT
MANGOHUD_ARCHIVE="$MANGOHUD_TMP_DIR/mangohud.tar.gz"
curl -fL "$MANGOHUD_URL" -o "$MANGOHUD_ARCHIVE"
tar -xzf "$MANGOHUD_ARCHIVE" -C "$MANGOHUD_TMP_DIR"
cd "$MANGOHUD_TMP_DIR/MangoHud"
./mangohud-setup.sh install
cd

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
