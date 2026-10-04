#!/usr/bin/bash

# This is taken straight from https://github.com/ublue-os/bazzite/blob/main/build_files/cleanup

set -eoux pipefail

rm -rf /tmp/* || true
rm -rf /var/log/dnf5.log || true
rm -rf /boot/* || true
rm -rf /boot/.* || true

# This invalidates libdnf5 package (chunkah)
# From https://github.com/ublue-os/aurora/pull/2580
rm -rf /usr/lib/sysimage/libdnf5/*
