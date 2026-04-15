# Talos FRR Extension

This extension provides [FRR (FRRouting)](https://frrouting.org/) as a Talos extension service, enabling a full routing suite directly on your Talos nodes.

## Installation

Add the extension to your `machine.install.extensions` list in the Talos machine configuration:

```yaml
machine:
  install:
    extensions:
      - image: ghcr.io/containdk/talos-frr-extension:<version>
```

## Configuration

The extension is configured using the `ExtensionServiceConfig` resource. This allows you to define the necessary FRR configuration files.

The following is a simplified example of how to configure BGP:

```yaml
apiVersion: v1alpha1
kind: ExtensionServiceConfig
name: frr
configFiles:
    - content: |
        zebra=yes
        bgpd=yes
        staticd=yes
      mountPath: /etc/frr/daemons
    - content: |
        !
      mountPath: /etc/frr/vtysh.conf
    - content: |
        frr defaults datacenter
        hostname talos-node
        log stdout
        !
        router bgp 65000
          bgp router-id 192.168.1.10
          neighbor 192.168.1.1 remote-as 65001
          neighbor 192.168.1.1 description Upstream Router
          !
          address-family ipv4 unicast
            neighbor 192.168.1.1 activate
            redistribute connected
          exit-address-family
        !
        line vty
        !
      mountPath: /etc/frr/frr.conf
```

## Troubleshooting

You can check the status and logs of the FRR service using `talosctl`:

```bash
talosctl service frr status
talosctl logs frr
```

To interact with FRR using `vtysh`, you can use `talosctl` to execute commands if necessary, though most interaction is done via providing configuration through the `ExtensionServiceConfig` resource.
