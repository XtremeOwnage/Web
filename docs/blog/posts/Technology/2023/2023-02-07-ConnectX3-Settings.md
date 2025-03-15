---
title: "ConnectX-3 Configuration"
date: 2023-01-23
tags:
  - Homelab
  - Networking
  - Networking/Mellanox
---

# How to configure ConnectX-3 via Linux

A quick guide on how to set common options with the ConnectX-3, via linux, without using the OFED driver.

This guide is specific to ethernet mode, but, may or may not work with infiniband mode.

<!-- more -->

## Depreciated!!!!

!!! warn
        A newer version of this post is available now.

[See: ConnectX Guide](../2025/ConnectX-Helpers.md)


## Software Needed

To perform general configuration of the ConnectX-3, we will need....

* ethtool
    * `apt-get install ethtool`
* ConnectX-3 set in ETHERNET mode.
    * [How to set ConnectX-3 to Ethernet](./2023-01-23-ConnectX3-PortMode.md){target=_blank}


## Configuration

Note, for the following steps, replace `enp1s0` with your interface.

If, you do not know how to find your interface's name, this guide likely isn't for you.

### Ring / Buffer Size

##### Get Values

`ethtool -g enp1s0`

```
# ethtool -g enp1s0
Ring parameters for enp1s0:
Pre-set maximums:
RX:             8192
RX Mini:        n/a
RX Jumbo:       n/a
TX:             8192
Current hardware settings:
RX:             8192
RX Mini:        n/a
RX Jumbo:       n/a
TX:             8192
```

##### Set Values

`ethtool -G enp1s0 rx 8192 tx 8192`

### Offloading

##### Get Values

`ethtool -k enp1s0`

``` bash
# ethtool -k enp1s0
Features for enp1s0:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: on
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp-mangleid-segmentation: off
        tx-tcp6-segmentation: on
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-gre-csum-segmentation: off [fixed]
tx-ipxip4-segmentation: off [fixed]
tx-ipxip6-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-udp_tnl-csum-segmentation: off [fixed]
tx-gso-partial: off [fixed]
tx-tunnel-remcsum-segmentation: off [fixed]
tx-sctp-segmentation: off [fixed]
tx-esp-segmentation: off [fixed]
tx-udp-segmentation: off [fixed]
tx-gso-list: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off
rx-vlan-stag-hw-parse: on
rx-vlan-stag-filter: on [fixed]
l2-fwd-offload: off [fixed]
hw-tc-offload: off [fixed]
esp-hw-offload: off [fixed]
esp-tx-csum-hw-offload: off [fixed]
rx-udp_tunnel-port-offload: off [fixed]
tls-hw-tx-offload: off [fixed]
tls-hw-rx-offload: off [fixed]
rx-gro-hw: off [fixed]
tls-hw-record: off [fixed]
rx-gro-list: off
macsec-hw-offload: off [fixed]
rx-udp-gro-forwarding: off
hsr-tag-ins-offload: off [fixed]
hsr-tag-rm-offload: off [fixed]
hsr-fwd-offload: off [fixed]
hsr-dup-offload: off [fixed]
```

##### Set Values


`ethtool -K enp1s0 tso on lro on`

``` bash
# ethtool -K enp1s0 tso on lro on
Actual changes:
rx-lro: off [requested on]
tx-tcp-ecn-segmentation: off [requested on]
tx-tcp-mangleid-segmentation: on
```








## Other Resources

### User's Manual

This manual contains many of the steps above, documented in better detail.

Page 68 contains ethtool specific documentation.

[User's Manual](https://dl.dell.com/manuals/all-products/esuprt_ser_stor_net/esuprt_pedge_srvr_ethnt_nic/mellanox-adapters_users-guide_en-us.pdf){target=_blank}