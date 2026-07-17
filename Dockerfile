# Use a temporary alpine image to generate the manifest
FROM alpine@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659 AS manifest
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
FROM quay.io/frrouting/frr:10.7.0@sha256:65e5967b922572c0565d968388fb06af69d7e9b3b3eea40ad7e3810687667f68 AS dist
RUN [ -r /etc/frr/vtysh.conf ] || touch /etc/frr/vtysh.conf
COPY docker-start /usr/lib/frr/docker-start

FROM scratch

COPY --from=manifest /manifest.yaml /manifest.yaml
COPY frr.yaml /rootfs/usr/local/etc/containers/frr.yaml
COPY --from=dist / /rootfs/usr/local/lib/containers/frr/
