---
title: "2023 Network Revamp, and Homelab History"
date: 2023-04-01
categories:
  - Technology
tags:
  - Homelab
  - Networking
---

# 2023 Network Revamp, and Homelab History

Going over the history of my home network from the previous three years... and...

Deploying a Brocade ICX-6450 and Dell R730XD, without increasing power consumption.

<!-- more -->

## Introduction

Back in Jan 2023, [My r720XD lost both of its PSUs](./2023-01-13-r720xd-death.md){target=_blank}. Even after acquiring a new PSU, it still had a lot of power errors being displayed. So, I felt it was time to lay it to rest and replace it.

Part of this project, I will be replacing it with a R730XD, then customizing the R730XD to be more energy efficient. 

As well, Back in Dec 2021, I [Removed my Brocade ICX-6610](https://xtremeownage.com/2021/12/12/reducing-power-consumption-without-reducing-performance/){target=_blank}. While, removal of the switch made a VERY distinct drop in my overall power utilization, I still found myself missing some of the capabilities of this switch. Mainly- the ability to do layer 3 routing, combined with layer 4 ACLs at line speed, on all ports, at the same time. 

BUT, I didn't want the noise, or power utilization of the ICX-6610. It was overly loud, and consumed a lot of energy.

However, I will be replacing my existing Zyxel GS1900-24EP with the Brocade ICX-6450-48P, in an attempt to aggregate my 10G backbone, and- without greatly increasing noise and energy consumption.



## Network / Homelab History

If you are not interested in the history of my home network, please feel free to [SKIP TO PLANNED CHANGES](#planned-changes)

### 2020

At this time, my network was pretty simple.

* Ubquitity EdgeRouter 5, POE 
* Unifi UAP-AC-PRO
* A Raspberry PI

That was it! In the time before COVID, and I had to physically goto work every day, I really didn't have any serious home infrastructure.

Pre-covid, I did start to experiment with home assistant, running it on a raspberry pi. But, there wasn't anything serious at this point.

Once COVID happened, and I started working from home, the amount of home-automation projects I started tackling skyrocketed. At this point, the pi-4 was not up to the task anymore with the demands I was placing on it.

So, I considered getting a synology NAS. After looking the prices- I felt I could built my own NAS, better AND cheaper.

[500$ Closet NAS Build](https://xtremeownage.com/2020/07/24/closet-mini-server-build/){target=_blank}

### 2021

Well, I started adding a ton of security cameras, and even more and more automation.

As such, the compute and networking demands on my home network were quickly increasing beyond what my infrastructure could provide.

So- I upgraded.

[10/40G Network Upgrade](https://xtremeownage.com/2021/09/04/10-40g-home-network-upgrade/){target=_blank}

* Brocade ICX-6610 1/10/40G switch
* Dell R720XD Running TrueNAS Scale

And- everything was fast. I had tons of spare capacity.

Here is the network as of the end of 2021.

![](./assets/2023-network-revamp/Network-Diagram-2021.webP)

### 2022

I learned that electricity bills can get pretty expensive. Especially when you have a record breaking heat wave, causing it to be 110F outside for two months STRAIGHT.

For literally two months, my Air condition would turn on around 8am, and would run until 2am the next morning try to keep the house cool.

For reference, here is my WH of AC utilization per day for 2022.

~[](./assets/2023-network-revamp/ac-energy-usage-2022.webP)

1.5 mWh of consumption, in July. From My A/C Alone. That is 120$ alone! Not including the load of all of my servers running.

I don't have a large house! 

So, the goal was to start trimming as much energy usage as possible.

If you wish to read about a few of the things performed in details- See [40G NAS Project](./../../../../pages/Projects/40G-NAS.md){target=_blank}

To summarize:

1. R720XD put on a massive hardware diet.
2. Additional, Newer more efficient SFFs added to take over compute loads from the inefficient E5-2667v2.
3. 10/40G Brocade replaced with 1G only Zyxel.

This managed to get my network power utilization down to around 375-450w average, from 500-600w. As well, it GREATLY reduced the amount of noise in the server room.

Here is a diagram of my network at the end of 2022.

![](./assets/2023-network-revamp/Network-Diagram-2022.webP)

#### Late 2022 - Kubernetes

I started learning about Kubernetes. Well, this caused the number of servers in my rack to increase by a few to support my newfound passion.

As well, I leveraged local NVMe on each of the nodes, with replicated ceph storage. Come to find out, ceph will completely annihilate the 1G link, which is also needed by control plane traffic. 

So, I needed to once again, establish 10G switching capabilities in my rack. I added a Unifi Aggregation Switch to handle this.

And, it is quite efficient in terms of power usage, generally using around 15w, with 4x 10G links connected, and a 1G link via 10GBase-T module.

### 2023

Again, I find my power consumption starting to creep up as I keep expanding out my Kubernetes environment. 

AND, [My r720XD died](./2023-01-13-r720xd-death.md){target=_blank}, and was replaced with a r730XD. (Documented below). Power consumption increased from 190w of my stripped down R720XD, up to ~250W for the new R730XD.

As well, I am REALLY missing some of the L3 routing capabilities I had with the Brocade ICX-6610.

The solution here, was to replace my Zyxel core switch, with a modified Brocade ICX-6450-48P.

The modifications are simple- Replacing the fans with quieter variants. The datasheet shows around a 30w idle consumption. 

## Planned Changes:

Here are the changes I hope to accomplish during this project:

1. 10G connectivity between all major components in my rack.
2. Simplified network design.
3. Reduced power consumption from putting the R730XD on a diet.
4. Some VLANs/ACLs will be moved from Opnsense to the new switch, reducing Opnsense overhead.
5. Removal of extra links 
    * 4-link lagg currently exists between Opnsense and the Zyxel switch.
        * Only a single 10G link for LAN, and a single 1G link for WAN after this is completed.
    * 6-total network connections between TrueNAS and other systems. 
        * Only a single 10G link to the aggregation switch will exist afterwards.
        * 40G point to point connection may be removed as well. Undetermined at this point.

Here is the planned network diagram:

![](./assets/2023-network-revamp/Network-Diagram-2023.webP)

!!! note "Why is the WAN connected to the Office/Bedroom switch??!?"
    For those wondering why my wan connects to the bedroom switch- its because the fiber is terminated there. I do not have/want to invest in the tools to properly re-terminate the fiber currently. 

    As such, it has an isolated vlan, which is only shared by the WAN port on the office/bedroom switch, and the WAN -> Firewall port on the Core Switch.

    Since, the link between the two switches is 10Gigabit, and the internet speed is 1Gigabit MAX, there are no concerns of bottlenecks here.

## Preparing / Modifying / Installing the Brocade ICX-6450-48-P