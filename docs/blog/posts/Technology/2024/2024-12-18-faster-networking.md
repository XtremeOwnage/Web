---
title: 2024 10G Or Faster
date: 2024-12-18
tags:
    - Homelab
    - Networking
    - Networking/Mikrotik
    - Networking/Unifi
hide:
  - navigation
---

# 10G or faster networking options.

Want connectivity faster then 10G?

Well- I have a list of NICs, switches, and notes.

<!-- more -->

!!! info
    This content is **NOT** sponsored.

    I do personally own these switch models mentioned below:
        - Unifi USW-Aggregation
        - Mikrotik CRS504-4XQ
        - Mikrotik CSS610-8G-2S+
        - Brocade ICX6610-48P
        - Brocade ICX6610-48
        - Brocade ICX6450-24P

    These switches were purchased by myself, with no undisclosed benefits.

    This post DOES include affiliate links. More information at the bottom of this post.

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

If you wish to run a 40/50/100G NIC at 10G, you will need a QSFP+ to SFP+ Adapter.

NONE of the listed NICs supports "Multi-gig", aka, 2.5G or 5G. You can, however, acquire SFP+ modules which may work.    This post is for 10G or faster, as such, no options for 2.5G / 5G are listed.

56Gbit/s is infiniband only, and only applies when running a Mellanox NIC, in IB mode, when connected to a supported infiniband switch.

Mellanox Infiniband NICs (Every one of the listed Mellanox NICs) can be ran in either ethernet mode (where they behave like a normal NIC), or Infiniband mode. I strongly recommend ETH mode. [Guide: Switch Port Mode](../2023/2023-01-23-ConnectX3-PortMode.md){target=_blank}

I personally prefer Mellanox NICs.

In my experiences, Intel, Mellonax, and Chelsio have all been plug and play with both Linux and Windows.

## Switches

Note, ALL switches listed, are MANAGED switches, with support for vlans.

### Table

Notes:
- Data used from manufacturer spec-sheets when possible.
- Footnotes are included for additional context.

|Manufacturer|Model              |Layer 3  |Max Speed|RJ45   |SFP|SFP+  |QSFP+|Multigig|Noise          |Power      |POE|Price |
|------------|-------------------|---------|---------|-------|---|------|-----|--------|---------------|-----------|---|------|
|Brocade     |ICX 6450-24        |Yes      |10G      |24     |-  |4     |-    |No      |37.9 dBA       |20-37w     |No |eBay  |
|Brocade     |ICX 6450-24P       |Yes      |10G      |24     |-  |4     |-    |No      |39.2 dBA       |21-400w[^14]|Yes|eBay  |
|Brocade     |ICX 6450-48        |Yes      |10G      |48     |-  |4     |-    |No      |37.2 dBA       |30-55w     |No |eBay  |
|Brocade     |ICX 6450-48P       |Yes      |10G      |48     |-  |4     |-    |No      |55.5 dBA       |31-776w[^14]|Yes|eBay  |
|Brocade     |ICX 6610-24        |Yes      |40G      |24     |-  |16[^15]|2[^15]|No      |39.6 - 48.7 dB |120-140w   |No |eBay  |
|Brocade     |ICX 6610-24P       |Yes      |40G      |24     |-  |16[^15]|2[^15]|No      |39.6 - 48.7 dB |120-140w   |Yes|eBay  |
|Brocade     |ICX 6610-48        |Yes      |40G      |48     |-  |16[^15]|2[^15]|No      |39.6 - 48.7 dB |165-185w   |No |eBay  |
|Brocade     |ICX 6610-48P       |Yes      |40G      |48     |-  |16[^15]|2[^15]|No      |39.6 - 48.7 dB |165-185w   |Yes|eBay  |
|Brocade     |ICX 7250-24        |Yes      |10G      |24     |-  |8     |-    |No      |41.9 dBA       |39-57w     |No |eBay  |
|Brocade     |ICX 7250-24P       |Yes      |10G      |24     |-  |8     |-    |No      |44.7 dBA       |48-454w[^14]|Yes|eBay  |
|Brocade     |ICX 7250-48        |Yes      |10G      |48     |-  |8     |-    |No      |44.5 dBA       |50-70w     |No |eBay  |
|Brocade     |ICX 7250-48P       |Yes      |10G      |48     |-  |8     |-    |No      |45.9 dBA       |70-942w[^14]|Yes|eBay  |
|Brocade     |ICX-7150-24        |Yes      |10G      |24     |-  |4     |-    |No      |Fanless        |14-24w     |No |eBay  |
|Brocade     |ICX-7150-24P       |Yes      |10G      |24     |-  |4     |-    |No      |41.4 dBA       |32-472w[^14]|Yes|eBay  |
|Brocade     |ICX-7150-48        |Yes      |10G      |48     |-  |4     |-    |No      |Fanless        |24-39w     |No |eBay  |
|Brocade     |ICX-7150-48P       |Yes      |10G      |48     |-  |4     |-    |No      |41.8 dBA       |47-491w[^14]|Yes|eBay  |
|Mikrotik    |CRS304-4XG-IN      |Yes**[^16]|10G      |1      |-  |4     |-    |Yes     |Fanless        |7-21w      |No |199$  |
|Mikrotik    |CRS305-1G-4S+IN    |Yes**[^16]|10G      |1      |-  |4     |-    |No      |Fanless        |10-18w     |No |120$  |
|Mikrotik    |CRS309-1G-8S+IN    |Yes**[^16]|10G      |1      |-  |8     |-    |No      |Fanless        |17-23w     |No |269$  |
|Mikrotik    |CRS310-1G-5S-4S+IN |Yes**[^16]|10G      |1      |5  |4     |-    |No      |Nearly Silent  |8-20w      |No |199$  |
|Mikrotik    |CRS326-4C+20G+2Q+RM|Yes**[^16]|40G      |20-24+1|-  |0-4   |2    |Yes     |36-54 dBA      |31-70w     |No |999$  |
|Mikrotik    |CRS504-4XQ-IN      |Yes**[^16]|100G     |-      |-  |-     |4[^12]|Yes     |Nearly Silent  |11-41w     |No |650$  |
|Mikrotik    |CRS510-8XS-2XQ-IN  |Yes**[^16]|100G     |1      |-  |8     |2    |Yes     |Silent - 40 dBA|15-45w     |No |999$  |
|Mikrotik    |CRS518-16XS-2XQ-RM |Yes**[^16]|100G     |1      |-  |16[^17]|2[^12]|No      |Nearly Silent  |15-95w     |No |1,595$|
|Mikrotik    |CSS318-16G-2S+IN   |No       |10G      |16     |-  |2     |-    |No      |Fanless        |10-13w     |No |139$  |
|Mikrotik    |CSS610-8G-2S+IN    |No       |10G      |8      |-  |2     |-    |No      |Fanless        |5-11w      |No |110$  |
|Unifi       |USW-Aggregation    |No       |10G      |-      |-  |8     |-    |No      |Silent?        |10-30w     |No |269$  |
|Unifi       |USW-Pro-Aggregation|Yes**[^18]|25G      |-      |-  |32    |-    |No      |Unknown        |?? - 100w  |No |899$  |


[^12]:
    This Mikroktik switch can support various speed configurations.
    
    Each QSFP+ port can do ONE of:
    
    1. 1x 100G
    2. 1x 50G
    3. 1x 40G
    4. 4x 25G
    5. 4x 10G
    6. 4x 5G
    7. 4x 2.5G
    8. 4x 1G
    9. 4x 100M
[^14]:
    This includes POE loads.
[^15]:
    Two of the rear 40G ports can only be used in 4x10G breakout.
[^16]:
    Mikrotik hardware can perform layer 3 routing without having dedicated hardware offload.
    
    If using the layer 3 functionality, double-check Mikrotik's documentation to ensure your required features are hardware offloaded.

    The majority of Mikrotik switches have limited CPU, and are not very effective for doing high-speed routing without hardware offload.
[^17]:
    These SFP+ ports are 25GBe.
[^18]:
    Don't buy a Unifi switch for its layer 3 capabilities. 
    
    You will be disappointed. Treat these as a layer 2 switch, and you will sleep better at night.

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

#### Mikrotik CRS518-16XS-2XQ-RM
- **Price:** $1,595
- **Capabilities:**
    - 2x 100G QSFP+, 16x25G SFP+, 1x 10/100M RJ45
    - This is a layer 3 switch. If using this for routing, make sure your features are hardware offloaded. The CPU is not very powerful.
- **Notes:**
    - Runs RouterOS Only.
- **Links**:
    - [Amazon](https://amzn.to/4gmFiVZ){target=_blank}
    - [Mikrotik](https://mikrotik.com/product/crs518_16xs_2xq){target=_blank}
    - [ServeTheHome](https://www.servethehome.com/mikrotik-crs518-16xs-2xq-rm-review-cheaper-25gbe-and-100gbe-switching-marvell){target=_blank}

#### Mikrotik CRS510-8XS-2XQ-IN
- **Price:** $999
- **Capabilities:**
    - 2x 100G QSFP+, 8x25G SFP+, 1x 10/100M RJ45
    - This is a layer 3 switch. If using this for routing, make sure your features are hardware offloaded. The CPU is not very powerful.
    - Can be powered via POE.
    - This- is essentially the same hardware as the CRS504-4XQ, but, with two of the 100G QSFP+ ports instead broken out into 8x 25G SFP+
- **Notes:**
    - Runs RouterOS Only.
- **Links**:
    - [Amazon](https://amzn.to/3P7QtGd){target=_blank}
    - [Mikrotik](https://mikrotik.com/product/crs510_8xs_2xq_in){target=_blank}
    - [ServeTheHome](https://www.servethehome.com/mikrotik-crs510-8xs-2xq-in-review-8-port-25gbe-2-port-100gbe-switch-marvell/){target=_blank}

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
    - Can be powered via POE.
- **Notes:**
    - Use the 1G port for management only; it does not share a backplane.
    - This is the central layer 3 router for my lab. Excellent switch.
    - Runs RouterOS Only.
- **Links**:
    - [Amazon](https://amzn.to/41BckgE){target=_blank}
    - [Mikrotik](https://mikrotik.com/product/crs504_4xq_in){target=_blank}
    - [ServeTheHome](https://www.servethehome.com/mikrotik-crs504-4xq-in-review-momentus-4x-100gbe-and-25gbe-desktop-switch-marvell/3/){target=_blank}

#### Mikrotik CRS326-4C+20G+2Q+RM
- **Price:** $999
- **Capabilities:**
    - 20x Multi-gig RJ45 (1/2.5/5G)
    - 4x "Combo" ports. Either Multi-gig RJ45, or 10G SFP+
    - 1x 10/100m Management Port
    - Noisy at startup, but, pretty quiet when running.
    - Layer 3** (If you use this as a router, make SURE the features you will be using are hardware offloaded. If the CPU processes packets- performance will be very, very slow.)
- **Notes**:
    - RouterOSv7
- **Links**:
    - [Amazon](https://amzn.to/41DhRmU){target=_blank}
    - [Mikrotik](https://mikrotik.com/product/crs326_4c_20g_2q_rm){target=_blank}
    - [ServeTheHome](https://www.servethehome.com/mikrotik-crs326-4c20g2qrm-switch-review-2-5gbe-10gbe-and-40gbe-marvell-qualcomm/){target=_blank}

#### Mikrotik CRS310-1G-5S-4S+IN
- **Price:** $199
- **Capabilities:**
    - 5x 1G SFP, 4x 10G SFP+, 1x 1G RJ45
    - Nearly silent. Low energy
    - Layer 3 (Limited to around 1G of routing throughput.)
- **Notes**:
    - SwOS or RouterOSv7
- **Links**:
    - [Amazon](hhttps://amzn.to/3BOA7ix){target=_blank}
    - [Mikrotik](https://mikrotik.com/product/crs310_1g_5s_4s_in){target=_blank}
    - [ServeTheHome](https://www.servethehome.com/mikrotik-crs310-1g-5s-4sin-fiber-switch/){target=_blank}


#### Mikrotik CRS309-1G-8S+IN
- **Price:** $269
- **Capabilities:**
    - 8 port SFP+, with 1x 1G RJ45
    - Silent and efficient.
    - Can be powered via POE
- **Notes**:
    - While this is a layer 3 switch- It does not have dedicated hardware offload, but, can offer reasonable routing performance (not linespeed!)
    - Can run either RouterOS, or SwOS
- **Links**:
    - [Amazon](https://amzn.to/4goepAX){target=_blank}
    - [Mikrotik](https://mikrotik.com/product/crs309_1g_8s_in){target=_blank}
    - [ServeTheHome](https://www.servethehome.com/mikrotik-crs309-1g-8sin-review-inexpensive-8x-10gbe-switch/){target=_blank}


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
    - [ServeTheHome](https://www.servethehome.com/mikrotik-crs305-1g-4sin-review-4-port-must-have-10gbe-switch/){target=_blank}

#### Mikrotik CRS304-4XG-IN
- **Price:** $199
- **Capabilities:**
    - 4 port layer 3 10G switch with 1x 1G Management Port
    - Silent and Efficient.
    - Very cost-effective 10G router.
    - This is a layer 3 switch.
    - Can be powered via POE.
    - Multi-gig capabilities (2.5G, 5G)
- **Notes:**
    - Use the 1G port for management only; it does not share a backplane.
    - This is the central layer 3 router for my lab. Excellent switch.
    - Runs RouterOS Only.
- **Links**:
    - [Amazon](https://amzn.to/49IPBBn){target=_blank}
    - [Mikrotik](https://mikrotik.com/product/crs304_4xg_in){target=_blank}
    - [ServeTheHome](https://www.servethehome.com/mikrotik-crs304-4xg-in-review-this-is-a-must-have-10gbase-t-marvell-switch/){target=_blank}

#### Mikrotik CSS610-8G-2S+IN
- **Price:** $139
- **Capabilities:**
    - 16x1G + 2x 10G SFP+
    - Silent and efficient.
    - Layer 2
- **Notes**:
    - SwOS only. 
    - I have been personally running one of these for 2 years now. Simple, and effective.
- **Links**:
    - [Amazon](https://amzn.to/3VNWTOB){target=_blank}
    - [Mikrotik](https://mikrotik.com/product/css610_8g_2s_in){target=_blank}
    - [ServeTheHome](https://www.servethehome.com/mikrotik-css610-8g-2sin-review-10gbe/){target=_blank}

#### Mikrotik CSS318-16G-2S+IN
- **Price:** $139
- **Capabilities:**
    - 16x1G + 2x 10G SFP+
    - Silent and efficient.
    - Layer 2
- **Notes**:
    - SwOS only.     
- **Links**:
    - [Mikrotik](https://mikrotik.com/product/css318_16g_2s_in){target=_blank}

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
    - [Datasheet](https://webresources.ruckuswireless.com/pdf/datasheets/ds-icx-6610.pdf){target=_blank}

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
    - [Datasheet](https://webresources.ruckuswireless.com/pdf/datasheets/ds-icx-6430-6450.pdf){target=_blank}

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
    - [Datasheet](https://www.commscope.com/globalassets/digizuite/61729-ds-icx-7150.pdf){target=_blank}

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
    - [Datasheet](https://docs.commscope.com/bundle/icx7250-installguide/page/GUID-A333FDA4-68CA-46D1-BB78-4A2B7F1DA37C.html){target=_blank}

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
    - A solid layer 2 switch.
- **Links**:
    - [Unifi](https://store.ui.com/us/en/products/usw-aggregation){target=_blank}
    - [Amazon](https://amzn.to/3BnGbyA){target=_blank}

#### Unifi USW-Pro-Aggregation
- **Price:** $899
- **Capabilities:**
    - 28x 10G SFP+
    - 4x 25G SFP+
        - **NOTE**: Does not support mixed speed!! All of these ports must run at the same speed. 
        - Either- all four are 25G, or all four are 10G. 
        - Mixed speed is supported for 10G or below.
        - This means, you CANNOT run 2x 25G, and 2x 10G. They will instead run at 4x 10G.
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

--8<--- "docs/snippets/non-sponsored.md"

--8<--- "docs/snippets/amazon-affiliate.md"

--8<--- "docs/snippets/ebay-affiliate.md"