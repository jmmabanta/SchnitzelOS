#!/bin/bash

set -ouex pipefail

# Setup Homebrew
systemctl preset brew-setup.service
systemctl preset brew-update.timer
systemctl preset brew-upgrade.timer

systemctl enable lactd
systemctl enable libvirtd
