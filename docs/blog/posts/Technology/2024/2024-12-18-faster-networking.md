---
title: 2024 10G Or Faster
date: 2024-12-18
tags:
    - Homelab
    - Networking
    - Networking/Mikrotik
    - Networking/Unifi
---

# 10G or faster networking options.

Want connectivity faster then 10G?

Well- I have a list of NICs, switches, and notes.

<!-- more -->

## Network Adapters

Note- price estimates last updated Dec 18, 2024.

I do not recommend picking up the 10G NICs. Instead, Spend 5 or 10$ more, and pick up one of the newer 25G NICs. They are compatible with 10G, but- are an entire generation newer.

This is also not a complete list. This list will be updated as I discover new NICs worthy of being added.


| Make             | Model                     | Ports     | Type                        | Speed                 | Generation            | Price                 | Link                                                                                                                                                                    | Notes                                                                                                                                                                 |
|------------|-----------------|---------|-----------------|---------------|-----------------|---------------|---------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| Mellanox     | MCX311A-XCAT        | Single    | SFP+                        | 10G                     | ConnectX-3[^2]    | $15-$25             | [eBay Link](https://ebay.us/V9Q6Eq){target=_blank}                                                                     | ASPM broken on newer Intel CPUs; works with `mlx4_core`. Recommended to choose 25G.     |
| Mellanox     | MCX312B                 | Dual        | SFP+                        | 10G                     | ConnectX-3[^2]    | $30-$40             | [eBay Link](https://ebay.us/aU5gI7){target=_blank}                                                                     | Consider ConnectX-4 10/25G instead.                                                                                                    |
| Mellanox     | MCX4111A                | Single    | SFP+                        | 25G                     | ConnectX-4            | $20-$40             | [eBay Link](https://ebay.us/5dn58j){target=_blank}                                                                     |                                                                                                                                                                             |
| Mellanox     | CX4121A                 | Dual        | SFP+                        | 25G                     | ConnectX-4            | $30-$40             | [eBay Link](https://ebay.us/Pm5SzF){target=_blank}                                                                     |                                                                                                                                                                             |
| Mellanox     | CX354A                    | Dual        | QSFP+                     | 40G                     | ConnectX-3[^2]    | $10-$20             | [eBay Link](https://ebay.us/fXd3Dw){target=_blank}                                                                     | Recommend newer NICs (e.g., ConnectX-4). Can support 10G with SFP -> QSFP adapter.     |
| Mellanox     | CX314A                    | Dual        | QSFP+                     | 40G                     | ConnectX-3[^2]    | $10-$20             | [eBay Link](https://ebay.us/Cz7Kih){target=_blank}                                                                     | Recommend newer NICs (e.g., ConnectX-4). Can support 10G with SFP -> QSFP adapter.     |
| Mellanox     | CX455                     | Single    | QSFP+                     | 100G                    | ConnectX-4            | $100                    | [eBay Link](https://ebay.us/lhTWMZ){target=_blank}                                                                     |                                                                                                                                                                             |
| Mellanox     | CX416A                    | Dual        | QSFP+                     | 100G                    | ConnectX-4            | $100-$200         | [eBay Link](https://ebay.us/Glpsya){target=_blank}                                                                     | This is the NIC I use in most of my servers.                                                                                    |
| Mellanox     | CX516A                    | Dual        | QSFP+                     | 100G                    | ConnectX-5            | $150-$300         | [eBay Link](https://ebay.us/rJTayB){target=_blank}                                                                     |                                                                                                                                                                             |
| Dell             | 099GTM[^4]            | Dual        | SFP+                        | 25G                     |                                 | $10-$20             | [eBay Link](https://ebay.us/7Q2TDQ){target=_blank}                                                                     | Compatible with many Dell servers (e.g., R730XD). Not picky with modules. 2x1G + 2x10G RJ45. Intel X540 |
| Dell             | 6VDPG[^5]             | Quad        | SFP+                        | 2x 1G + 2x 10G|                                 | $20-30                | [eBay Link](https://ebay.us/6Rr1p9){target=_blank}                                                                     | I do NOT recommend getting this NIC. It is extremely picky with modules |
| Dell             | R887V[^1]             | Quad        | RJ45                        | 2x 1G + 2x 10G|                                 | $10-$20             | [eBay Link](https://ebay.us/dKP98K){target=_blank}                                                                     | Compatible with many Dell servers (e.g., R730XD). Not picky with modules.                        |
| Intel            | X540-T2[^3]         | Dual        | RJ45                        | 10G                     |                                 | $15-$30             | [eBay Link](https://ebay.us/VkKMRt){target=_blank}                                                                     | These work well when you need a copper 10G link.                                                                         |
| Chelsio        | T520-CR                 | Dual        | SFP+                        | 10G                     | T5                            | $30-$70             | [eBay Link](https://ebay.us/H1GmFL){target=_blank}                                                                     |                                                                         |
| Chelsio        | T540-CR                 | Quad        | SFP+                        | 10G                     | T5                            | $40-$100            | [eBay Link](https://ebay.us/toNXXN){target=_blank}                                                                     | One of the few quad 10G NICs.                                                                        |
| Chelsio        | T580-CR                 | Dual        | QSFP+                     | 40G                     | T5                            | $20-$60             | [eBay Link](https://ebay.us/VO9Ced){target=_blank}                                                                     |                                                                         |
| Chelsio        | T6225-CR                | Dual        | SFP+                        | 25G                     | T6                            | $50-$150            | [eBay Link](https://ebay.us/2W7XGR){target=_blank}                                                                     |                                                                         |


[^1]:
        The Dell R887V is based on the ConnectX-4 CX4121C

        While the rx3x generation is not listed as compatible- I CAN confirm this does work in my r730XD.
[^2]:
        These are dirt-cheap for a reason. I strongly recommend buying ConnectX-4 or newer NICs.

        The price difference is not much, and they are better supported.
[^3]:
        I generally recommend avoiding RJ45 for 10G.

        The SFP+ modules use 10GBase-T. These run extremely hot, and have high energy consumption.
[^4]:
        This is DELL Specific.

        I can confirm this works on both r720XD, and r730XD.

        Please do research to ensure if this is compatible with your chassis.
[^5]:
        This is DELL Specific.

        Do NOT buy this unless you are absolutely certain this is what you want.

        These are EXTREMELY picky on modules. I was unable to get my server to boot without a supported module.

        Neither my Cisco, Mellanox, or Unifi SFP+ modules, or DACs would function.

### Notes

Please keep in mind, compatible speeds for a given network adapter.

25G NICs will nearly always also support 10G. (and slower)

100G NICs, can generally support anything less.

If you wish to run a 40/50/100G NIC at 10G, you will need a QSFP to SFP+ Adapter.

NONE of the listed NICs supports "Multi-gig", aka, 2.5G or 5G. You can, however, acquire SFP+ modules which may work.    This post is for 10G or faster, as such, no options for 2.5G / 5G are listed.

56Gbit/s is infiniband only, and only applies when running a Mellanox NIC, in IB mode, when connected to a supported infiniband switch.

Mellanox Infiniband NICs (Every one of the listed Mellanox NICs) can be ran in either ethernet mode (where they behave like a normal NIC), or Infiniband mode. I strongly recommend ETH mode. [Guide: Switch Port Mode](../2023/2023-01-23-ConnectX3-PortMode.md){target=_blank}

I personally prefer Mellanox NICs.

In my experiences, Intel, Mellonax, and Chelsio have all been plug and play with both Linux and Windows.

## Switches

Note, ALL switches listed, are MANAGED switches, with support for vlans.

### Mikrotik

All of the listed Mikrotik options are acquired new.

Mikrotik hardware will either run RouterOS, or SwOS.

SwOS is a very basic interface, which only exposes basic layer 2 switching, and vlan functionality.

RouterOS, exposes the kitchen sink of networking features.

!!! warning
        Do- check for hardware offload for the features you are interested in, however, as non-hardware offloaded features may have a gimped backplane connection.

        For example- My CRS504-4XQ can handle line-speed 100G routing, without breaking a sweat.

        If I enable a non-offloaded feature, such as smart-queues, NAT, or non-offloaded filtering- it would need to be process by the CPU. The CPU link works at [1Gbps MAX](https://cdn.mikrotik.com/web-assets/rb_images/2162_hi_res.png){target=_blank}

        This is 100 times slower.

I have found Amazon to be the best place to buy. Mikrotik only sells to other distributors.

#### Mikrotik CRS504-4XQ-IN
- **Price:** $650
- **Capabilities:**
    - Ports can support ONE OF:
        - 1x 100GBe
        - 1x 40GBe
        - 4x 25GBe
        - 4x 10GBe
    - Silent and low power usage (~25W without load).
        - With 3x 100G + 4x10G, This switch consumes around 35 watts in my lab.
    - Cheapest 100GBe switch option. (One of the cheapest options for 25G too)
    - This is a layer 3 switch.
- **Notes:**
    - Use the 1G port for management only; it does not share a backplane.
    - This is the central layer 3 router for my lab. Excellent switch.
    - Runs RouterOS Only.
- **Links**:
    - [Amazon](https://amzn.to/41BckgE){target=_blank}
    - [Mikrotik](https://mikrotik.com/product/crs504_4xq_in){target=_blank}

#### Mikrotik CRS305-1G-4S+IN
- **Price:** $120
- **Capabilities:**
    - 4-port 10G Layer 3 switch.
    - Silent and efficient.
- **Notes**:
    - While this is a layer 3 switch- It does not have dedicated hardware offload, and is barely capable of routing 1Gbit/s. I only recommend using this for layer 2.
    - Can run either RouterOS, or SwOS
- **Links**:
    - [Amazon](https://www.amazon.com/s?k=CRS305-1G-4S%2BIN&crid=1QPNN89FD06ZZ&sprefix=crs504-4xq-in%2Caps%2C400&ref=nb_sb_noss_2){target=_blank}
    - [Mikrotik](https://mikrotik.com/product/crs305_1g_4s_in){target=_blank}

### Brocade

All of the following brocade switches are acquired used, from eBay or other sources.

If you decide on picking up a brocade switch, I strongly recommend checking out [Fohdeesha's Website](https://fohdeesha.com/docs/brocade-overview.html){target=_blank}

These are best acquired from eBay, or other resellers.

#### Brocade ICX6610
- **Price:** $100 (Can go as low as $40)
- **Capabilities:**
    - Line-speed Layer 3 routing across all ports.
    - 2x 40G QSFP, 16x 10G SFP+, 48x 1G POE.
    - Supports BGP, OSPF, RIP, NTP, and DHCP server.
- **Notes:**
    - **EXTREMELY** loud. (Extremely difficult to make these quieter)
    - High power consumption (~150W average).
    - Absolute unit of a switch. Can get these dirt-cheap. Just- be prepared for it to be hot and loud.
    - Comes in 24, or 48 port variants, with, and without POE.
- **Links**:
    - [Ebay](https://ebay.us/T1tiQ8){target=_blank}
    - [Fohdeesha](https://fohdeesha.com/docs/fcx.html){target=_blank} This is a setup guide, along with license unlocks, etc. Make **SURE** to go through these steps.

#### Brocade ICX6450
- **Price:** $60 average
- **Capabilities:**
    - 4x 10G SFP + 24 or 48 port options (POE optional).
    - Supports OSPF and RIP (no BGP).
- **Notes:**
    - Fan mods are easy and can reduce power usage (~40-50W).
    - Runs nearly silent with fan mods.
    - Comes in 24, or 48 port variants, with, and without POE.
- **Links**:
    - [Ebay](https://ebay.us/t4VL0U){target=_blank}
    - [Fohdeesha](https://fohdeesha.com/docs/icx6450.html){target=_blank} This is a setup guide, along with license unlocks, etc. Make **SURE** to go through these steps.

#### Brocade ICX7150
- **Price:** $100-150 average
- **Capabilities:**
    - 4-8 10G SFP+, 24-48 1G, with optional POE. Depending on configuration.
    - Supports OSPF and RIP (no BGP).
- **Notes:**
    - Very quiet. Silent when ran in fanless mode.
    - Comes in 24, or 48 port variants, with, and without POE.
- **Links**:
    - [Ebay](https://ebay.us/wyo9XF){target=_blank}
    - [Fohdeesha](https://fohdeesha.com/docs/icx7150.html){target=_blank} This is a setup guide, along with license unlocks, etc. Make **SURE** to go through these steps.
    - [Specs](https://docs.commscope.com/bundle/icx7150-technicalspecification/page/GUID-45937574-0953-40F5-84A9-16FBF4F408B7.html){target=_blank}

#### Brocade ICX7250
- **Price:** $50-150 average
- **Capabilities:**
    - 4-8 10G SFP+, 24-48 1G, with optional POE. Depending on configuration.
    - Supports OSPF and RIP (no BGP).
- **Notes:**
    - Pretty quiet under normal working conditions. 40-45dBA on spec sheets.
    - Can be ran in fanless mode with reduced POE output.
    - Comes in 24, or 48 port variants, with, and without POE.
    - 30-50w consumption at idle, without POE. From spec sheets.
- **Links**:
    - [Ebay](https://ebay.us/t4VL0U){target=_blank}
    - [Fohdeesha](https://fohdeesha.com/docs/icx7250.html){target=_blank} This is a setup guide, along with license unlocks, etc. Make **SURE** to go through these steps.
    - [Secs](https://docs.commscope.com/bundle/icx7250-installguide/page/GUID-A333FDA4-68CA-46D1-BB78-4A2B7F1DA37C.html){target=_blank}

### Mellanox

You can pick up used Mellanox infiniband switches for pretty cheap.

#### Mellanox SX6036
- **Price:** $75-150 average
- **Capabilities:**
    - 36 QSFP+ (40 / 56GBe)
- **Notes:**
    - This switch supports infiniband.
    - This- is a very cost-effective switch, for 40GBe. (or 56G infiniband)
    - As I do not own one of these- I cannot give more details.
- **Links**:
    - [Ebay](https://ebay.us/pcaJgV){target=_blank}
    - [Secs](https://cw.infinibandta.org/files/showcase_product/120330.104655.244.PB_SX6036.pdf){target=_blank}

### Unifi

Unifi's switches are silent, and efficient.

I generally recommend buying these from Unifi.

#### Unifi USW-Aggregation
- **Price:** $269
- **Capabilities:**
    - 8x SFP+ (10GBe)
- **Notes:**
    - 8 port layer 2 10G Switch. Silent.
    - My switch with all 8 ports in use, with either fiber modules, or DACs, uses around 10w average.
- **Links**:
    - [Unifi](https://store.ui.com/us/en/products/usw-aggregation){target=_blank}
    - [Amazon](https://amzn.to/3BnGbyA){target=_blank}

#### Unifi USW-Pro-Aggregation
- **Price:** $899
- **Capabilities:**
    - 28x 10G SFP+ + 4x 25G SFP+
- **Notes:**
    - 32 port "layer 3" switch.
    - I **STRONGLY** do not recommend buying a Unifi switch, for its layer 3 capabilities. If you buy this switch, Then consider it a layer 2 switch.
- **Links**:
    - [Unifi](https://store.ui.com/us/en/products/usw-aggregation){target=_blank}
    - [Amazon](https://amzn.to/4foKEP9){target=_blank}

## Additional Notes

### Configuration
- Most NICs arrive ready to use. Use `ethtool` to adjust hardware offload parameters if needed:
    [Documentation on ConnectX-3 Configuration](../2023/2023-02-07-ConnectX3-Settings.md)

- For setting port modes between ETH/IB:
    [Documentation on ETH/IB Mode](../2023/2023-01-23-ConnectX3-PortMode.md)

## Disclaimers

--8<--- "docs/snippets/amazon-affiliate.md"

--8<--- "docs/snippets/ebay-affiliate.md"