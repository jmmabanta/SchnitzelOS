#!/bin/bash

set -ouex pipefail

IMAGE_NAME="SKIP_PACKAGE_INSTALL" \
AKMODNV_PATH="/tmp/rpms/nvidia" \
MULTILIB=1 \
/tmp/rpms/nvidia/ublue-os/nvidia-install.sh

rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json
ln -sf libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so
