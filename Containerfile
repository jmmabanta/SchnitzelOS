ARG FEDORA_VERSION=44

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# Includes codecs + secureboot signing for akmods
FROM ghcr.io/ublue-os/silverblue-main:${FEDORA_VERSION}

# This is required for Helium Browser to install
RUN rm /opt && mkdir /opt 

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/10-ogc.sh \
    /ctx/20-packages.sh \
    /ctx/30-nvidia.sh \
    /ctx/40-services.sh \
    /ctx/50-cleanup.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
