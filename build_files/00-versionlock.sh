#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

# Prevents partial upgrades on these packages which can causes breakages

dnf5 versionlock add "qt6-*" "plasma-desktop"
dnf5 versionlock add "libzstd"

echo "::endgroup::"
