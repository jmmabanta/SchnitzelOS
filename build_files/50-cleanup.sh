#!/usr/bin/bash

# This is taken straight from https://github.com/ublue-os/bazzite/blob/main/build_files/cleanup

set -eoux pipefail

rm -rf /tmp/* || true
rm -rf /var/log/dnf5.log || true
rm -rf /boot/* || true
rm -rf /boot/.* || true
