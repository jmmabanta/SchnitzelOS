ARG FEDORA_VERSION=44

FROM ghcr.io/ublue-os/akmods:ogc-${FEDORA_VERSION} AS akmods
FROM ghcr.io/ublue-os/akmods-nvidia-open:ogc-${FEDORA_VERSION} AS akmods-nvidia
FROM ghcr.io/ublue-os/brew:latest AS brew

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY --from=brew /system_files /system_files
COPY system_files /system_files
COPY build_files /

# This is required for Helium Browser to install

# Includes codecs + secureboot signing for akmods
FROM ghcr.io/ublue-os/silverblue-main:${FEDORA_VERSION}
# Helium needs access to /opt directly, not the symlink to /var/opt
RUN rm /opt && mkdir /opt 

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=akmods,src=/kernel-rpms,dst=/tmp/kernel-rpms \
    --mount=type=bind,from=akmods-nvidia,src=/rpms,dst=/tmp/rpms/nvidia \
    /ctx/10-ogc.sh && \
    /ctx/20-packages.sh && \
    /ctx/30-nvidia.sh && \
    /ctx/40-services.sh && \
    /ctx/50-cleanup.sh && \
    /ctx/60-image-info.sh && \
    /ctx/70-build-initramfs.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
