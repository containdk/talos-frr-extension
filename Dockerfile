# Use a temporary alpine image to generate the manifest
FROM alpine@sha256:3f4d6b32e26703c6082839234f43769d5046b3ac7c910033911d1e71d8cd630a AS manifest
ARG VERSION
RUN cat > /manifest.yaml <<EOF
version: v1alpha1
metadata:
  name: frr
  version: "${VERSION}"
  author: Netic
  description: |
    [contrib] Provides a frr routing daemon running on the host
  compatibility:
    talos:
      version: ">= v1.12.0"
EOF

# Grab the official image to use as base of extension
FROM quay.io/frrouting/frr:10.7.1@sha256:e995beaa50fdc9edb35eadcfefa29b7f062cc06f2b812613789b68fa541554d2 AS dist
RUN [ -r /etc/frr/vtysh.conf ] || touch /etc/frr/vtysh.conf
COPY docker-start /usr/lib/frr/docker-start

FROM scratch

COPY --from=manifest /manifest.yaml /manifest.yaml
COPY frr.yaml /rootfs/usr/local/etc/containers/frr.yaml
COPY --from=dist / /rootfs/usr/local/lib/containers/frr/
