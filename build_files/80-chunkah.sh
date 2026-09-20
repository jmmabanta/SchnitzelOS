#!/usr/bin/bash

set -ouex pipefail

# Here we mark certain system_files to better inform chunkah on
# how to package them
# https://github.com/coreos/chunkah#customizing-the-layers

setfattr -n user.component -v "flatpak-tweaks" /usr/lib/systemd/system/flatpak-add-fedora-repos.service
setfattr -n user.component -v "flatpak-tweaks" /usr/lib/systemd/system/flatpak-preinstall.service
setfattr -n user.component -v "flatpak-tweaks" /usr/lib/systemd/user/bazaar-daemon.service
setfattr -n user.component -v "flatpak-tweaks" /usr/libexec/replace-fedora-flatpak
setfattr -n user.component -v "flatpak-tweaks" /usr/share/flatpak/preinstall.d/bazaar.preinstall
setfattr -n user.update-interval -v "yearly" /usr/lib/systemd/system/flatpak-add-fedora-repos.service

setfattr -n user.component -v "nvidia-tweaks" /usr/lib/systemd/system/sync-nvidia-flatpak.service
setfattr -n user.component -v "nvidia-tweaks" /usr/lib/systemd/user/niri-focused-booster.service
setfattr -n user.component -v "nvidia-tweaks" /usr/lib/bootc/kargs.d/00-nvidia.toml
setfattr -n user.component -v "nvidia-tweaks" /usr/libexec/sync-nvidia-flatpak
setfattr -n user.update-interval -v "yearly" /usr/lib/systemd/system/sync-nvidia-flatpak.service

setfattr -n user.component -v "misc-tweaks" /usr/lib/bootc/kargs.d/10-zswap.toml
setfattr -n user.component -v "misc-tweaks" /usr/lib/systemd/system/libvirt-workarounds.service
setfattr -n user.component -v "misc-tweaks" /usr/lib/tmpfiles.d/swtpm-workaround.conf
setfattr -n user.component -v "misc-tweaks" /usr/local/bin/regenerate-grub
setfattr -n user.component -v "misc-tweaks" /usr/local/bin/xdg-open
setfattr -n user.component -v "misc-tweaks" /usr/share/plymouth/themes/spinner/watermark.png
setfattr -n user.update-interval -v "yearly" /usr/lib/bootc/kargs.d/10-zswap.toml

setfattr -n user.component -v "base-conf" /etc/rpm-ostreed.conf
setfattr -n user.component -v "base-conf" /etc/wireplumber/wireplumber.conf.d/90-dualsense.conf
setfattr -n user.component -v "base-conf" /etc/uupd/config.json
setfattr -n user.component -v "base-conf" /etc/udev/rules.d/99-powercap.rules
setfattr -n user.component -v "base-conf" /etc/udev/rules.d/99-rapoo-vt3.rules
setfattr -n user.component -v "base-conf" /etc/systemd/network/50-wired.link
setfattr -n user.component -v "base-conf" /etc/polkit-1/rules.d/50-efibootmgr.rules
setfattr -n user.update-interval -v "yearly" /etc/rpm-ostreed.conf

setfattr -n user.component -v "signing-files" /etc/containers/policy.json
setfattr -n user.component -v "signing-files" /etc/containers/registries.d/schnitzel-os.yaml
setfattr -n user.component -v "signing-files" /etc/pki/containers/schnitzel-os.pub
setfattr -n user.update-interval -v "yearly" /etc/containers/policy.json

setfattr -n user.component -v "niri-conf" /etc/niri/
setfattr -n user.update-interval -v "yearly" /etc/niri/config.kdl
