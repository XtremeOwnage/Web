---
title: 2024 Network Revamp
date: 2024-11-23
tags:
  - Homelab
  - Networking/Mikrotik
  - Networking/Unifi
---

# 2024 Network Revamp

In the current state- I have WAN -> UXG-Lite -> Everything else.

But, there are quite a few things which drives me crazy about unifi...

1. No "easy" support for IPv6 GIF tunnels- I have an entire /48 block of IPv6 addresses I would like to use. I don't want to go do a bunch of hacks to get this to work.
2. Traffic policies, etc, only work when apparently you use the Unifi as the primary DNS. I don't want to do this.
3. Unifi's Layer 3 routing protocol support, is still questionable. But, at least it supports OSPF now.... 
4. I honestly hate its ACL interface. Its... horrible when you have lots of zones, lots of ACLs, etc.

To meet these needs, I decided to pick up a new [hEX refresh](https://mikrotik.com/product/hex_2024){target=_blank}

For 59$ shipped, this thing is nearly half of the price as the EdgeRouters used to sell for- back before the Unifi line was even introduced- and Unifi was known for the most cost-effective routers in existence.

In addition, for this price point- it has extremely respectable hardware specs, and is more then capable of handling my gigabit fiber.

### The Goals

I want to remove the UXG from being in-line with general lab traffic. It does NOT work... at all, with traffic handled by other routers. It, just produces broken graphs, charts, etc.

I WOULD use the USW-24-Pro as a router.... BUT, it has a ton of issues...

- <https://www.reddit.com/r/UNIFI/comments/1e7irs5/do_not_buy_a_unifi_layer_3_switch_expecting_it_to/>
- <https://community.ui.com/questions/Layer-3-Switch-Static-Routes-do-NOT-work/5f7e98ac-745c-4437-b74c-cefe5630deaa>

It, honestly, sucks as a layer 3 router. (And- also, breaks many of the unifi features when you use it as a layer 3 router.... No traffic inspection, for example... despite the traffic still flowing through the UXG/UDR/etc...) Broken routing.

So- instead, I'll let Unifi do what Unifi is good at- Managing simple LAN traffic with upstream delegation.

I'll use the new Mikrotik hEX, to do what the Unifi is not good at. Managing multiple VPN tunnels, terminating GIF tunnels, and handling routing... using BGP for internal route propagation. 

Won't, really be any changes for the lab subnets- HOWEVER, I will be re-locating the hEX, and UXG ouside of my server rack- which will allow my rack to be completely unplugged, without affecting LAN traffic.

## The Plan

The hex will be added logically, directly behind the incoming WAN connection.

Its duty, will be simple.

1. Maintain PPPoe connection.
2. Maintain IPv6 GIF tunnel.
3. Perform IPv6 Suffix Remapping (Aka, It takes the public ipv6 suffix, and remaps to a private suffix- this makes my internal devices and subnets immune to any external changes. For example- if my ISP ever offers native IPv6- I can adopt it with no internal changes needed.)
4. Perform NAT for IPv4 traffic. 
5. Perform Port Forwarding
6. ACLs for WAN -> Edge (Edge, is the zone between WAN & TRUST / PUBLIC)
7. ACLs for TRUST -> Edge (Trust Zone- refers to everything in my "Lab")
8. ACLs for PUBLIC -> Edge (Public Zone- Aka, LAN traffic, Users, Guest subnets, etc.)
9. Maintain VPN Client Access
10. Maintain Outgoing VPN Tunnels

### Logical Routing Diagram

Logical Diagram, showing major Zones marked.

``` mermaid
flowchart TD
    subgraph OUTER
        WAN 
    end

    WAN--> | PPPoe| HEX

    subgraph EDGE
        HEX
    end

    subgraph PUBLIC
        UXG
        UXG["Unifi UXG-Lite"] --> V_LAN & V_Guest & V_LAN_Isolated
    end
    
    HEX --> |Static| UXG
    HEX --> |BGP| 100G
    subgraph TRUSTED
        100G["CRS504-4XQ"] --> V_Kubernetes & V_Server & V_Storage
    end

    100G --> | BGP | EDGEMAX

    subgraph UNTRUSTED
        EDGEMAX["EdgeRouter"] --> V_IOT & V_SECURE & V_MGMT
    end
```

### Physical Diagram

Here is a physical diagram, with the major locations marked, and connection type.

``` mermaid
flowchart TD
    WAN

    subgraph Office
        MC["Media Converter"]
        SW-B[CSS610-8G-2S]

    end


    subgraph Closet["Server Closet"]
        UXG["UXG-Lite"]
        HEX["hEX Refresh"]
        SW-L["USW-Lite 8 POE (LAN)"]
        SW-S["USW-Lite 8 POE (Secure)"]

    end

    subgraph Rack["Server Rack"]
        100G[CRS504-4XQ]
        Edge["EdgeMax"]

        %% Layer 2 Switches
        10G["USW-Aggregation"]
        1G["USW-24-Pro"]

        S_1G["Servers 1G"]
        S_10G["Servers 10G"]
        S_100G["Servers 100G"]
    end

    %% Access Points
    AP1["UAP-AC-PRO"]
    AP2["U6 Pro"]
    SW-G["USW-Flex (Garage)"]
    SW-T["USW-Flex (Livingroom)"]

    %% OUTER --> EDGE
    WAN --> | GPON |MC
    MC --> | 1G CAT6 | HEX

    %% EDGE --> Trust
    HEX --> | 1G CAT6 | 1G

    %% EDGE --> PUBLIC
    HEX --> | 1G CAT6 | UXG

    %% PUBLIC
    UXG --> | 1G POE |SW-L
    SW-L --> | 1G POE |SW-G
    SW-L --> | 1G POE |SW-T   

    %% TRUST
    1G --> |10G DAC | 100G    
    1G --> |10G MMF| 10G
    100G --> |10G DAC| 10G

    10G --> | 10G SMF| SW-B

    1G --> | 1G CAT6| SW-S



    1G --> | 1G CAT6 | S_1G
    10G --> | 10G Twinax | S_10G
    100G --> | 100G DAC| S_100G

    %% IOT
    1G --> | 1G CAT6| Edge

    %% Access Points
    SW-L --> | 1G POE |AP1 & AP2
```

## Individual Zones

### EDGE

The Edge zone is responsible for performing ACLs between OUTER/WAN, and Internal Zones.

It also performs NAT for IPv4 traffic, and prefix mapping for IPv6 traffic.

It handles route propagation using BGP.

And, it handles traffic policies for external traffic. (aka, selective routing of traffic through tunnels.)

### PUBLIC / LAN

Since, Unifi is actually pretty good at managing LAN subnets- I am going to set it up as if the hEX router is the ISPs router. 

It will have a delegated /58 IPv6 Prefix, which will give it the ability to automatically manage, and delegate /64 blocks as needed to any subnets it manages.... up to 64 subnets.

It will also be delegated a /18 block of IPv4 addresses, which will allow it to automatically manage, and delegate up to 64 x /24 blocks of IPv4 addresses.

As such- this allows the ability for it to automatically assign and maintain up to 64 internal subnets, as needed for various purposes. Although, realistically, only 2 subnets are actually used here.

1. General LAN Traffic (aka, normal Wifi). NAT handled by the hEX.
2. Guest / Internet Only (Isolated subnet, which can ONLY talk to the internet. NOTHING internally. This- is used for certain devices, like... My cat-feeder, and, Guest wifi access. Wireless Isolation enabled too.). Outbound to WAN is NAT-ed here.

As.... many of the Unifi features only works, when it is used as the primary DNS/DHCP server- it will be used as the primary DNS/DHCP server. 


### TRUST / Homelab / Servers

The majority of my server rack lives in the "TRUSTED" Zone. Everything here is routed using the 100G CRS504-4XQ, which does an amazing job. Very minimal ACLs are applied here, rather- Vlans are used for isolation here needed..

Since, everything in my lab is running proxmox, with the exception of a Synology- All of my firewall rules are done in Proxmox (Synology does its own Layer 3 ACLs). This is fantastic, as the firewall rules are stored WITH the VMs. I can manage everything in one place. All of my VMs/LXCs have configured firewall policies via Proxmox.

Routes are propagated to/from hEx using BGP. I have found, BGP w/BFD works really nicely for internal routing, and load balancing. Extremely fast route propagation, and EXTREMELY customizable, as needed.

For Addressing-

1. /16 block of IPv4 addresses will be delegated to this zone. This gives 256 total /24 usable subnets.
2. /56 block of IPv6 addresses will be delegated to this zone. This gives 256 total /64 usable subnets.

DNS is handled by Technetium as the primary DNS server. The backup/failover DNS is handled by a Bind9 server, using zone transfers from the primary.

DHCP is also handled by Technetium.

All physical servers with hardware clocks, are automatically configured as a NTP pool, via Ansible playbooks. Chrony is used here.

All Virtual Machines, LXCs, etc... are configured to use said NTP pool, via Ansible Playbooks.

### UNTRUSTED / IOT / Security / etc...

As someone who does a lot of home automation, I have a lot of IOT devices. I also have lots of security cameras, etc.

I have been using an old EdgeRouter, I purchased over a decade ago, for maintaining these zones. It- works perfectly. It also can propagate routes using BGP, (or RIP/OSPF), and does support BFD.

This zone, is more or less, completely isolated inside of the network. 

The devices inside of this zone- Can't really talk to anything. 

There is no access outside of the subnets, with very few limitations. No DNS. NTP is provided by the EdgeMAX. DHCP is provided by the EdgeMAX.

- My ESPHome Subnet, can talk to home assistant. Home assistant can talk to it.
- My generic IOT subnet, cannot talk to anything. Home assistant can talk to it. (This is for devices, such as Kasa- that I don't want phoning home. BUT, home assistant can fetch/control them).
- V_Secure- The only access allowed into this subnet- is from my reverse proxy to the blue iris interface. No access is allowed to external. 
- V_Management - Management interfaces for switches, routers, etc. Separate VRFs are used on devices to isolate the management traffic, from everything else. 


## Final Words

I am not doing this, to fix an issue, Honestly- I really wanted to experiment with the new hex refresh routers.

The hardware seems extremely capable, and the price point is really hard to beat.

If- this works as I have planned- It should also make network management quite a bit easier.