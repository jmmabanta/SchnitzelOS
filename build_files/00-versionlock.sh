#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

# Prevents partial upgrades on these packages which can causes breakages

VERSIONLOCK=(
  "qt6-*"
  "plasma-*"
  libzstd
  zstd
)
dnf5 versionlock add "${VERSIONLOCK[@]}"

echo "::endgroup::"
