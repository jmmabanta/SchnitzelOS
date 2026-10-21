#!/usr/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Here we mark certain system_files to better inform chunkah on
# how to package them
# https://github.com/coreos/chunkah#customizing-the-layers

setfattr -n user.component -v "flatpak-tweaks" /usr/lib/systemd/system/flatpak-add-fedora-repos.service
setfattr -n user.component -v "flatpak-tweaks" /usr/lib/systemd/system/flatpak-preinstall.service
setfattr -n user.component -v "flatpak-tweaks" /usr/lib/systemd/user/bazaar-daemon.service
setfattr -n user.component -v "flatpak-tweaks" /usr/libexec/replace-fedora-flatpak
setfattr -n user.component -v "flatpak-tweaks" /usr/share/flatpak/preinstall.d/default.preinstall
setfattr -n user.update-interval -v "yearly" /usr/lib/systemd/system/flatpak-add-fedora-repos.service

setfattr -n user.component -v "nvidia-tweaks" /usr/lib/systemd/system/sync-nvidia-flatpak.service
setfattr -n user.component -v "nvidia-tweaks" /usr/lib/bootc/kargs.d/00-nvidia.toml
setfattr -n user.component -v "nvidia-tweaks" /usr/libexec/sync-nvidia-flatpak
setfattr -n user.update-interval -v "yearly" /usr/lib/systemd/system/sync-nvidia-flatpak.service

setfattr -n user.component -v "misc-tweaks" /usr/lib/bootc/kargs.d/10-zswap.toml
setfattr -n user.component -v "misc-tweaks" /usr/lib/bootc/kargs.d/20-eacv2.toml
setfattr -n user.component -v "misc-tweaks" /usr/lib/systemd/system/libvirt-workarounds.service
setfattr -n user.component -v "misc-tweaks" /usr/lib/tmpfiles.d/swtpm-workaround.conf
setfattr -n user.component -v "misc-tweaks" /usr/lib/tmpfiles.d/libvirt-workarounds.conf
setfattr -n user.component -v "misc-tweaks" /usr/lib/sysusers.d/libvirt-workarounds.conf
setfattr -n user.component -v "misc-tweaks" /usr/local/bin/regenerate-grub
setfattr -n user.component -v "misc-tweaks" /usr/local/bin/xdg-open
setfattr -n user.component -v "misc-tweaks" /usr/local/bin/check-eacv2-reqs
setfattr -n user.component -v "misc-tweaks" /usr/share/plymouth/themes/spinner/watermark.png
setfattr -n user.component -v "misc-tweaks" /usr/lib/sysctl.d/99-splitlock.conf
setfattr -n user.component -v "misc-tweaks" /usr/lib/sysctl.d/99-disable-kexec.conf
setfattr -n user.update-interval -v "yearly" /usr/lib/bootc/kargs.d/10-zswap.toml

setfattr -n user.component -v "base-conf" /etc/rpm-ostreed.conf
setfattr -n user.component -v "base-conf" /etc/wireplumber/wireplumber.conf.d/90-dualsense.conf
setfattr -n user.component -v "base-conf" /etc/uupd/config.json
setfattr -n user.component -v "base-conf" /etc/udev/rules.d/99-powercap.rules
setfattr -n user.component -v "base-conf" /etc/udev/rules.d/99-rapoo-vt3.rules
setfattr -n user.component -v "base-conf" /etc/udev/rules.d/81-wol.rules
setfattr -n user.component -v "base-conf" /etc/udev/rules.d/72-disable-dualsense-touchpad.rules
setfattr -n user.component -v "base-conf" /etc/polkit-1/rules.d/50-efibootmgr.rules
setfattr -n user.component -v "base-conf" /etc/xdg/gnome-xdg-terminals.list
setfattr -n user.component -v "base-conf" /etc/xdg/umbriel-xdg-terminals.list
setfattr -n user.component -v "base-conf" /etc/xdg-desktop-portal/umbriel-portals.conf
setfattr -n user.update-interval -v "yearly" /etc/rpm-ostreed.conf

setfattr -n user.component -v "signing-files" /etc/containers/policy.json
setfattr -n user.component -v "signing-files" /etc/containers/registries.d/schnitzel-os.yaml
setfattr -n user.component -v "signing-files" /etc/pki/containers/schnitzel-os.pub
setfattr -n user.update-interval -v "yearly" /etc/containers/policy.json

# Additions from aurora pr 3028

HOMEBREW_TARBALL=/usr/share/homebrew.tar.zst
setfattr -n user.component -v "homebrew" "${HOMEBREW_TARBALL}"

# rpm-ostree creates tmpfiles from packages having owned files in /{var,run}
RPM_OSTREE_TMPFILES=/usr/lib/rpm-ostree/tmpfiles.d
setfattr -n user.component -v "rpm-ostree-tmpfiles.d" "${RPM_OSTREE_TMPFILES}"
# vibes, shouldn't change super often
setfattr -n user.update-interval -v "quarterly" "${RPM_OSTREE_TMPFILES}"

FONTCONFIG_CACHE=/usr/lib/fontconfig/cache
setfattr -n user.component -v "fontconfig-cache" "${FONTCONFIG_CACHE}"
# also vibes, no idea how often this changes, but it seems to change often
setfattr -n user.update-interval -v "daily" "${FONTCONFIG_CACHE}"

find /usr /etc /opt -newermt '1970-01-01T00:00:00Z' -exec touch -h -a -m -d '1970-01-01T00:00:00Z' {} +

echo "::endgroup::"
