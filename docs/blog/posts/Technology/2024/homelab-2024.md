---
title: 2024 Homelab status
date: 2024-12-28
tags:
    - Homelab
---

# My homelab - End of 2024

This post will go over my lab, as a whole as of December 2024.

![Picture of the front of my rack](assets-2024-lab/rack-front.webP)

<!-- more -->

## Overview

I will split this post into a few sections.

1. [Compute](#compute)
    - Discuss the servers, and workloads.
2. [Storage](#storage)
    - Discuss the various types of storage used.
    - Backups
3. [Power](#power)
    - How is my lab powered? 
    - Solar-powered lab
    - How are outages handled?
4. [Networking](#networking)
    - A overview of how the network is setup, technologies used.
5. [Issues / Complaints"](#issues--complaints)
    - What I want to improve on.
5. [Rack Accessories, Organization, Cables](#rack-organization)
    - This- is the section for things seen in the rack. Finger trays, custom enclosures, the rear-mounted power management, etc.
    - This section also includes links to all of the cables used, Ethernet, Fiber, DACs, SAS, etc.
    - If anyone is looking for any of the specific products you see in my rack, I will include links.


But- first, a brief overview.

### Pictures

#### Rack itself

This, is the front of my rack.

![Picture of the front of my rack](assets-2024-lab/rack-front.webP)

This- is the bottom, rear of the rack.

![Picture of the bottom, rear of my rack](assets-2024-lab/rack-rear-bottom.webP)

This, is the top-rear. I have my PDUs, and ATS mounted here.

![Picture of the top, rear of my rack. Two PDUs, and a ATS visible](assets-2024-lab/rack-rear-top.webP)

This, is the top of the rack, looking down. (The ESP you see is a BT proxy for Home Assistant)

![Looking from the top, down inside of the rack.](assets-2024-lab/rack-top-down.webP)

When- I am not working on my rack, It lives in the closet.

![Picture of the rack hidden away in the closet](assets-2024-lab/closet-rack.webP)

#### Power Delivery

I will go into this more in-depth further down- but, I have a pretty comprehensive power delivery system, with a few redundancies

![Picture of my mains panels, inverter, batteries, and other electrical gizmos in the garage](../../Solar/assets/FinishedProduct_2.webP)

![Exterior wall of the house with transfer switch, meter can, shutoff, and other boxes](../../Solar/assets/ExteriorWall_Finished.webP)

## Compute

### Servers / Hardware

For servers, I have a balance between small, efficient hardware and enterprise servers.

I run 5 machines, 24x7. The compute element of my lab uses around 350-400 watts.

ALL of my servers run Proxmox as the base OS. 

#### Optiplex SFFs

First- I have a pair of optiplex SFFs- These are the "core" compute elements of my lab.

These machines are reasonably efficient, and quite flexible. 

![Picture showing the SFFs in my rack with a red square](./assets-2024-lab/SFFs-Circled.webP)

- 2x Optiplex 5060 SFF [Ebay: Optiplex 5060 SFF](https://ebay.us/UVsUiU){target=_blank}[^ebay]
    - i7-8700 (6c / 12t @ 3.20ghz)
    - 64G DDR4 (MAX Ram: 64G, 4 DIMMs, No ECC)
    - LSI 9287-8e SAS HBA (External) [eBay: LSI 9287-8e](https://ebay.us/O73eWN)[^ebay]
        - This connects to the MD1220 disk shelf, which contains both SAS and SATA SSDs primarily used for CEPH.
        - Each SFF, has access to "Half" of the shelf. (The shelf is running in "split" mode)
    - Mellanox ConnectX-4 CX-416A 100GBe Dual Port NIC [eBay: ConnectX-4 CX-416A](https://ebay.us/W0nsy0){target=_blank}[^ebay]
        - This is the primary network connection.
        - One port on each host connects to the 100G switch
        - The other port, is used for failover, and is connected to my 10G Unifi Aggregation Switch.
        - I picked these up for around 125$ each.
    - 128G Kioxia NVMe [eBay: 128G Kioxia NVMe](https://ebay.us/r4L130){target=_blank}[^ebay]
        - These things are dirt-cheap, and make great boot drives.
    - **Power**: These machines average around 50 watts. 
        - These are the backbone of my ceph cluster, which houses the majority of my lab's storage.
        - 100GBe + SAS Controllers, does not do any favors for energy consumption.

These machines are literally the backbone of my ceph cluster. The i7-8700 offers pretty good performance, and runs the bulk of my VMs.

#### Optiplex Micros

Next up, I have a pair of Optiplex Micros.

![Picture showing the Optiplex Micros in my rack, Circled](./assets-2024-lab/Optiplex-Micros.webP)


??? note "If- you are curious about the enclosure- Its homemade in my garage (Click to expand..)"
    I honestly, was not very happy with the outcome of this enclosure- However, it does work well.

    ![](./assets-2024-lab/micro-enclosure-1.webP)

    ![](./assets-2024-lab/micro-enclosure-2.webP)

    ![](./assets-2024-lab/micro-enclosure-3.webP)

    All of the imperfections are hidden by blanks.

    ![](./assets-2024-lab/micro-enclosure-4.webP)

##### (Left) Optiplex Micro 3070m 

[eBay: Optiplex 3070m](https://ebay.us/oCNyPq){target=_blank}[^ebay]

Specs:

- **CPU**: i5-9500t (6c / 6t @ 2.20ghz)
- **RAM**: 24G DDR4
- **Boot Drive**: Samsung 980 1T [[Amazon]](https://amzn.to/4gM0ZhU){target=_blank}[^amazon]
- **NVR Storage**: Samsung 870 QVO 4T SATA [[Amazon]](https://amzn.to/3DsBtjH){target=_blank}[^amazon]
    - This- is the primary storage for my NVR.
    - SSD is used here instead of spinning rust for power efficiency. 
    - Also, makes accessing historical footage, snappy fast.
- **Power**: This machine averages around 20w, while running my NVR 24/7/365.

While this machine is inside of my proxmox cluster, its primary purpose is to run my NVR.

It runs a Blue Iris VM, with over a handful of 5MP Reolink POE Cameras. It does an amazing job of it.

It also runs a kubernetes VM, where Frigate runs. Frigate has a USB-Type C Coral TPU attached for object detection.

##### (Right) Optiplex 7050m

[eBay: Optiplex 7050m](https://ebay.us/GXjVcD){target=_blank}[^ebay]

Specs:

- **CPU**: i7-6700 (4c / 8t # 3.40ghz)
- **RAM**: 16G DDR4
- **Boot Drive**: 256G Liteon SATA SSD
- **VM Storage**: 1T Samsung 980 1TB
- **Power**: 10w average.

This, is one of the oldest machines in my lab. Its extremely efficient, and it works very well.

Its silent. Its efficient.

This is also the ONLY machine I have local storage for VMs. 

This machine hosts my Home Assistant VM, and a backup DNS server, both of which are on local storage.

These- are on local storage- to ensure my home assistant remains working, even when I break my network....

#### Rack Servers

Now- we get to the big hardware.

![The two dell rack servers in my rack circled](./assets-2024-lab/rack-servers.webP)

##### (Top) Dell R730XD

[[Ebay: Dell R730XD]](https://ebay.us/z2Fhg0)[^ebay]

- **Processor**: 2x [E5-2697a V4](https://www.intel.com/content/www/us/en/products/sku/91768/intel-xeon-processor-e52697a-v4-40m-cache-2-60-ghz/specifications.html){target=_blank} (16c / 32t @ 2.6/3.6ghz ). Total: 32c, 64t
- **Memory**: 256GB DDR4 ECC (16 of 24 DIMMs populated)
- **Primary NIC**: 100Gbit Mellanox CX-4 [[eBay]](https://ebay.us/W0nsy0){target=_blank}[^ebay]
- **Secondary NIC**: Dell 8887V ConnectX-4121C Dual port 25GBe [[eBay]](https://ebay.us/xaBbgX){target=_blank}[^ebay]
    - Not used. These- are honestly DIRT cheap. They are literally only 11$ as of right now.
    - Very nice NIC though.
- **Storage**: 
    - 16x M.2 NVMe
        - I really like my NVMe. If you can't tell.
    - 4x 16T 3.5" SATA
    - 8x 8T 3.5" SATA
    - 32G Samsung FIT
        - This runs Clover bootloader. My r730xd cannot boot from the M.2 which contains proxmox.
        - So- I have a thumb drive which contains clover, which automatically boots into proxmox.
    - 32G Samsung FIT
        - Unraid's Boot Drive
- **HBA**: Dell P2R3R PERC HBA330 Mini [[eBay]](https://ebay.us/ro1bQe)[^ebay]
    - This is a JBOD-ONLY HBA. I replaced the raid HBA with this, for use with ZFS.
    - This is passed directly into the Unraid VM.
- **Power Consumption**: Yes.
    - This server is an energy hog.
    - **Average Consumption**: 238w

??? note "Expansion Slot Details. Click to expand"
    - **Slot 1**: "Generic" dual M.2 cards [[Amazon]](https://amzn.to/4fLf0vL){target=_blank}[^amazon]
        - 2x Samsung 1T PM963 Enterprise NVMe [[eBay]](https://ebay.us/sjMRc8){target=_blank}[^ebay]
        - [Blog Post: Installing more NVMe into the r730XD](../2023/2023-08-13-r730xd-more-nvme.md){target=_blank}
        - 4x4 bifurcation
    - **Slot 2**: "Generic" dual M.2 cards [[Amazon]](https://amzn.to/4fLf0vL){target=_blank}[^amazon]
        - 2x Samsung 1T PM963 Enterprise NVMe [[eBay]](https://ebay.us/sjMRc8){target=_blank}[^ebay]
        - 4x4 bifurcation
    - **Slot 3**: Mellanox ConnectX-4 CX-416A 100GBe Dual Port NIC [[eBay]](https://ebay.us/W0nsy0){target=_blank}[^ebay]
        - This is the primary network adapter used. 
        - Installed in one of the x8 short slots. (Limits max throughput to around 60Gbit/s)
        - No bifurcation
    - **Slot 4**: Asus Hyper M.2 [[Amazon]](https://amzn.to/404xvX5){target=_blank}[^amazon]
        - 4x Samsung 1T PM963 Enterprise NVMe [[eBay]](https://ebay.us/sjMRc8){target=_blank}[^ebay]
        - 4x4x4x4 bifurcation
    - **Slot 5**: Quad M.2 PLX Switch
        - [Post: Adding Bifurcation to the r720XD](../2022/R720XD-Bifurcation.md){target=_blank} (More detail about the cards, what cards to get, installation, etc.)
        - These were originally used in the r720xd, but, are now used in the r730xd too, just to squeeze in a few more M.2
        - No bifurcation
        - 1x Samsung 1T PM963 Enterprise NVMe [[eBay]](https://ebay.us/sjMRc8){target=_blank}[^ebay]
            - Proxmox Boot Drive
        - 2x Samsung 970 Evo Plus NVMe
            - Unraid ZFS Cache Pool (Mirrored)
        - 1x Samsung 970 Evo NVMe
            - Unraid "Scratch/Cache" Pool
    - **Slot 6**: Asus Hyper M.2 [[Amazon]](https://amzn.to/404xvX5){target=_blank}[^amazon]
        - 4x Samsung 1T PM963 Enterprise NVMe [[eBay]](https://ebay.us/sjMRc8){target=_blank}[^ebay]
        - 4x4x4x4 bifurcation

A fair amount of hardware is passed directly into Unraid.

??? note "Unraid Passthrough Hardware (Click to expand)"

    - Unraid VM
        - **CPU**: 32 Cores (Logical, Not Physical)
        - **Memory**: 64G
        - 2x Samsung 970 Evo Plus NVMe
            - These are used in a Mirrored ZFS Pool, INSIDE of Unraid. This- is my primary cache pool.
        - 1x Samsung 970 EVO 1TB
            - This is used as another cache pool, for certain applications which are frequently writing data.
            - Non-redundant.
        - 8x 8T Seagate Exos
            - In 2021, I ordered 12x of these USED.
            - It will be 2025 in less than two weeks, I have only had to return a single drive.
            - Four of these are used in a ZFS Striped Mirror combination, for my "Important" data.
            - One is used in the main Unraid "Array"
        - 4x 16T Sata
            - Three are WD Drives. The fourth is a Seagate Iron Wolf.
            - These form the main Unraid "Array", where I do bulk storage duties.
        - 32G Samsung FIT
            - This is my original flash drive for unraid, purchased in 2020.
            - This is Unraid's boot drive.
    
!!! note "Purpose"
    This server's primary purpose is to host the Unraid VM, and its associated storage.

    It also hosts a significant amount of NVMe storage used with Ceph.

    I have HA rules configured to try to prioritize other hardware, as the other hardware uses less energy for a given amount of compute.

    HOWEVER- This machine has enough resources to literally host EVERYTHING. It has LITERALLY half of the resources.

    64 of the 102 CPUs is from this machine. 256G of the 416GB of ram is from this machine.

    ![Image showing resources available for proxmox](./assets-2024-lab/proxmox-resources.webP)

    Maintenance is much easier when you have enough resources to live-migrate multiple machines at a time.

    This machine was acquired after my [R720 Died at the beginning of 2023.](../2023/2023-01-13-r720xd-death.md){target=_blank}

!!! note "Unraid's Purpose"
    The primary purpose of Unraid, is for my "Media center".

    It hosts plex, along with a handful of containers which supports media streaming.

    It is also my primary SMB, and NFS host.

##### (Bottom) Dell R720XD

The r720XD is the server which was used in my [40G NAS Project](../../../../pages/Projects/40G-NAS.md){target=_blank}.

After it [died last year](../2023/2023-01-13-r720xd-death.md), the r730xd was picked up to replace it. 

Its use case: Storage for DDR3 DIMMs, Unused 10G NICs, Extra HBAs, etc.

It makes a very useful drawer in my rack.

??? note "R720XD Specs"

    - **CPU**: 2x [Intel Xeon E5-2667v2](https://www.intel.com/content/www/us/en/products/sku/75273/intel-xeon-processor-e52667-v2-25m-cache-3-30-ghz/specifications.html){target=_blank}
        - 8c / 16t @ 3.3/4.0Ghz
    - **Memory**: 128G DDR3
    - **HBA**: Dell Perc H310 Flashed to IT Mode
        - [Fohdeesha Guide](https://fohdeesha.com/docs/H310-full.html){target=_blank}

### Applications / Services

#### Proxmox

As previously stated, Proxmox runs bare metal on all of my servers. 

It has built in ceph cluster management, built in firewall rules, ACLs... It has built in backups, and overall, its just a fantastic base OS.

Once upon a time, I did run Kubernetes (microk8s) bare metal. However, while out on a work-related trip, The cluster decided to.... Not work.

Everything was wiped the following week, and Proxmox was installed bare metal. It has been that way ever since.

#### Kubernetes

Kubernetes is used to run around 90% of my containers. 

I am currently running Rancher + K3s. 

My K3s cluster has 7 VMs, scattered amongst the various servers. 

![Image showing the proxmox summary for my k3s pool](./assets-2024-lab/k3s-vms-summary.webP)

1. rancher
    - This is a VM which only runs a single docker container, containing rancher.
        - I do this, to allow me to separately upgrade and maintain rancher, as rancher itself, is used to upgrade and maintain the cluster.
2. rke-master-1
    - This is the master server. I only run a single master, as I rely on hypervisor redundancy here.
        - A single master reduces complexity, where the proxmox cluster itself, can handle the redundancy.
3. k8s-admin
    - Generic admin box. Gotta manage the cluster!
4. Worker VMs (4)
    - 1-3, have HA policies which prefers a specific machine. In this case, Both SFFs, and the r730XD get a VM.
    - In the event of issues, cluster maintenance, these VMs are free to migrate as needed.
    - rke-worker-4, this node is tainted to only allow NVR-related activities to run. It is pinned to the optiplex micro which runs my NVR.

#### Unraid

Unraid itself, is running as a VM, on the R730XD. It is noted here as it runs all of the "media-related" compute.

Aka, all of the associated docker containers, runs directly on unraid.

## Storage

Storage for my lab is provided by a few different means.

1. CEPH
    - Ceph provides the primary storage used for both Proxmox VMs, LXCs, and Kubernetes containers.
    - Hosted by both [Optiplex SFFs](#optiplex-sffs) as well as the [R730XD](#top-dell-r730xd).
    - [Blog Post: Building a ceph cluster](../2023/2023-08-08-proxmox-ceph.md)
        - While- I have quite a few more OSDs now, and have 100G networking instead of 10G- Its still the same basic cluster.
2. Unraid
    - Unraid provides SMB, and NFS storage.
    - Its primary use-case is providing energy efficient BULK storage.
    - As noted [above](#top-dell-r730xd), it is running as a VM on the r730xd.
3. Synology
    - This is used for backups only.
    - [Blog Post: My Backup Strategies](../2024/2024-06-11-Backup-Strategies.md){target=_blank}
        - This goes over how backups are performed from Kubernetes, Unraid, and Proxmox.

Inside of the rack- you may have noticed the storage arrays as well.

!!! note
    To note, While I really enjoy the flexibility and reliability of ceph- 

    I don't feel it is the perfect solution for my needs. Its just the best solution I have tested so far.

    Ideally, I'd love a better solution, which is Distributed, Flexible, and Reliable.... That also integrates with Proxmox & Kubernetes.

    Perhaps 2025 will bring something.....[^NotAHint]

[^NotAHint]: Note- I am not hinting at anything here.

### Storage - Hardware

![Image showing the various storage hardware circled](./assets-2024-lab/storage-circled.webP)

#### Dell MD1220

[Ebay: Dell MD1220](https://ebay.us/NV0dY1){target=_blank}[^ebay]

Specs:

- **Bays**: 24x 2.5" SAS / SATA
- **Controllers**: 2x 6Gbit SAS
- **Power Consumption**: 45 watts. Empty shelf will use 35-40 watts.

??? note "Purpose"
    This storage shelf's only purpose is to present a JBOD of SSDs to the two [Optiplex SFFs](#optiplex-sffs). 

    All of the installed SSDs are used by ceph.

    This shelf is running in "Split Mode". This "Splits" the shelf between  both SFFs.

    For- more information, please read the [MD1200 series manual](https://dl.dell.com/manuals/common/powervault-md12xx-om-en-us.pdf){target=_blank}, Page 19-20.

As a random note- my shelf arrived with 24x 2.5" 15k SAS disks. Nearly 300 watts worth of them.

#### Dell MD1200

Specs:

- **Bays**: 12 3.5" SAS / SATA
- **Controllers**: 2x 6Gbit SAS
- **Power Consumption**: Empty shelf will use 35-40 watts.
    - Fully loaded with 3.5" disks, this shelf will consume around 150w, 24/7.
    - 3.5" disks, 8-12w each.

??? note "Purpose"
    This shelf does not yet have a purpose.

    I have been trying to decide between two potential use-cases.

    1. Moving all of my unraid storage to this shelf, giving unraid the ability to migrate around the cluster, as SAS can multipath.
    2. Offline / Cold storage.

    Until a purpose has been determined, this shelf is powered off.

#### Synology DS423+

I picked this model specifically, due to its Intel processor. 

If- I ever wanted to repurpose this into a plex streaming box, the integrated quicksync iGPU would become extremely handy.

??? note "Hardware Specs"
    - **CPU**: Intel Celeron J4125
    - **RAM**: 18GB
        - 2GB is on the board itself.
        - I added an additional 16G Curcial stick. Max "Officially" supported RAM is 6GB. Can confirm, it works. Exact ram used is linked below.
        - [Amazon](https://amzn.to/3ZKXQs5){target=_blank}[^amazon]
        - [Newegg](https://www.newegg.com/crucial-16gb-260-pin-ddr4-so-dimm/p/N82E16820156262){target=_blank}
    - **Storage**: 4x 8T Seagate Exos
    - **Storage (NVMe)**: 1x Samsung 970 Evo.
        - Used as READ cache.

As stated above- this box's sole purpose is backups, and replication.

[Read more: My backup strategies](../2024/2024-06-11-Backup-Strategies.md){target=_blank} (This post details exactly how it is used.)

Also notable- I am using SMB, NFS, and iSCSI Multipathing to get 2Gbits of throughput consistently. This was much more effective then using LACP.

[Post: How to: Synology Multipathing](2024-07-22-Synology-Multipath.md){target=_blank} (Outlines how to configure SMB, NFS, and iSCSI multipathing to take FULL advantage of multiple NICs without using LACP.)

### Storage - Software

#### Ceph

Ceph is the primary storage used for my VMs, Containers, LXCs, etc.

The cluster consists of both [SFFs](#optiplex-sffs), and the [R730XD](#top-dell-r730xd). 

A total of 17 SSDs are used as OSDs in my cluster currently. 8 NVMes hosted by the r730xd, the rest enterprise SATA or SAS SSDs inside of the Optiplex SFFs, or the [MD1220](#dell-md1220).

The reason I use ceph- is not performance... but, rather reliability, and flexibility.

In terms of flexibility, both proxmox and kubernetes have built-in support for Ceph storage. Spinning up storage for new containers, VMs, LXCs... is effortless as a result.

In terms of reliability, as long as ONE of the three storage nodes is online, My storage is fully usable. I run 3 copies of each piece of data, which is distributed across all three nodes.

Performance, is nothing to write home about. I'll just note- it works. And performance isn't an issue.... (Although, I don't have any workloads hosted on ceph, which are I/O dependant.)

If- you want to learn more about my ceph cluster setup, I have my [Ceph Cluster: Documentation](../2023/2023-08-08-proxmox-ceph.md){target=_blank}.

#### Unraid

Ok, so, I have went back and forth over the years between Unraid, and TrueNAS.

If- you want to know more about why I use Unraid these days, Please see [My history with Unraid & TrueNAS](./2024-12-24-TrueNAS-Unraid.md){target=_blank}

But- for now, I will summarize why I use Unraid-

1. Its simple.
2. Its reliable.
3. It works.
4. Its flexible.
5. It is THE most efficient way (power-wise) for storing large libraries of write once, read many files. 
    - It ONLY needs to spin up a single HDD to access a given file, instead of spinning up an entire array.

##### Unraid's Purpose

Unraid has a simple purpose in my lab.

It provides file shares. Both NFS, and SMB.

It provides BULK data over FILE shares. (Aka, When I need to store dozens of terabytes of data.... Like Archiving linux ISOs)

It provides ZFS pools for data I want to keep very safe. In addition to having [sanoid configured](https://github.com/jimsalterjrs/sanoid){target=_blank}, Its data is backed up daily to my synology.

It does not host ANY block storage. It DOES run docker containers, specifically related to "media". I run them here, instead of my kubernetes cluster to remove the need to transmit bulk data over the network.

#### Synology

My synology's primary use-case, is backups. 

If- you didn't see the post already- [My backup strategies](./2024-06-11-Backup-Strategies.md){target=_blank}

The above post- will detail how the synology is used, with details, screenshots, etc.

It does run a single container for minio. This container ONLY replicates data from the minio instance hosted on my Unraid server.

## Power

Power- is the element of my lab which has received the most attention and funding.

As- the power in my city has been historically unstable, and unreliable- I have taken many steps to attempt to compensate.

Back in 2021, I [built a homemade UPS out of a hand truck, and a LiFePO4 battery](https://xtremeownage.com/2021/06/12/portable-2-4kwh-power-supply-ups/){target=_blank}. It has went through quite a few outages, and has held up beautifully. Although- It might be replaced very soon..... with [a solar generator](./2024-12-20-solar-generator-ups.md){target=_blank}[^ThisISaHint].

[^ThisISaHint]: This IS hinting at an upcoming project...

In 2022, I made the decision to completely redo the power for my entire house, and outfit the entire home with solar power generation, and battery backup for EVERYTHING. This project was completed early 2023.

If- you are interested to learn more about this project- Please see.... [My Solar Project](../../../../pages/Projects/Solar-Project.md){target=_blank}

Nonetheless- Lets dig into how everything works.

### Mains power delivery

#### Mains Power Diagram

Here is a diagram which details the flow of mains power through my house.

``` mermaid
flowchart LR
    UTILITY["Utility Pole"] --> Meter
    subgraph Exterior
        Meter
        Shutoff["Grid Disconnect Switch"]
        ATS["Automation Transfer Switch"]        
    end

    subgraph Garage     
        MainPanel["Main Breaker Panel"]
        BackupPanel["Critical Loads Panel"]
        Battery["Battery Bank"]
        Inverter["Main Inverter"]
        Inverter2["AC to DC Charger"]
    end

    subgraph Exterior2["Exterior"]
        Generator
    end

    subgraph Loads
        Server["Server Room"]
        L["Various Loads"]
    end

    Meter --> Shutoff --> | Grid Up| ATS --> MainPanel --> L

    Shutoff --> Inverter --> BackupPanel --> Server

    BackupPanel -.-> | Grid Down| ATS

    Battery --> Inverter

    Generator -.-> |AC| Inverter2 -.-> |48V DC|Battery
```

Lets start on the exterior of the house.

#### Exterior

![Image showing the various boxes on the exterior of my house, annotated](./assets-2024-lab/power-exterior.webP)

Power comes into my meter from the pole- this part is pretty standard.

After, the first box, is just a switch which will isolate my house from the GRID. 

Next- we enter the ATS (Automation transfer switch). This- is where most of the magic happens.

!!! info "How the ATS is configured"
    My main breaker panel connects to the transfer switch.

    When in "normal" operation, the transfer switch is connected to the grid. 

    However, when grid frequency, voltage goes out of spec, the ATS will switch to "backup" mode. 

    In backup mode, The transfer switch is fed from a 60amp breaker in my "Critical loads panel", which is fed directly from the inverter.

    This means- when the grid goes down- the entire house is powered directly from the inverter.

In addition, there is a rapid shutdown breaker, which will cause the solar panels to become inactive.

All of the needed cables enter a race, which leads to the garage on the other side of the house.

#### Garage

Inside of the garage, is where all of the fancy hardware is stored.

![Picture showing the inside of my garage, with loads of electrical panels annotated with purpose](./assets-2024-lab/power-garage.webP)

Note- this is an older picture- I have moved the battery rack, and installed an additional box which contains hardware for monitoring energy.

[Post: Adding Per-Breaker Energy Monitoring](../../Solar/solar-part-4-monitoring.md){target=_blank} (This post details both the software, and hardware used to monitor energy consumption.)

Power enters the garage through the bottom box, and goes inside of the cable race. From there- the main breaker panel is fed directly from the transfer switch.

The Inverter, is connected on the MAINS side of the transfer switch.

The critical loads panel, is connected directly to the inverter. 

The rack on the left currently contains a total of 20kwh of LiFEPO4 batteries, with 4/6 bays filled. The inverter is capable of 10-12kw continuous power, and up to 24kw peak bursts.

It is fully capable of running the ENTIRE HOUSE, including the central AC unit, when fully off grid.

A year or so back- this was tested. After a 100mph wind gust knocked out power for nearly two zipcodes, I [ran completely off grid for most of a week](../../Solar/june-2023-lessons-learned.md){target=_blank} (Of course- everything was documented, including lessons learned)

The server rack, is fed directly from the critical loads panel. If grid power drops, there is a maximum of 6ms before it is powered from battery.

Honestly- there is no need for a UPS at this point.

???+ note "Generator Power"
    In the event the batteries are nearly discharged, and the sun is not shining, I will start up the [Harbor freight predator 9000 generator.](https://www.harborfreight.com/9000-watt-gas-powered-portable-generator-with-co-secure-technology-carb-72935.html){target=_blank}

    This- is not an inverter generator, and tends to produce pretty noisy power when under load.

    This is documented [in this post](../../Solar/june-2023-lessons-learned.md){target=_blank}

    To compensate for this, The generator feeds directly into a [5,000 watt 48V DC Charger](https://signaturesolar.com/eg4-chargeverter-gc-48v-100a-battery-charger-5120w-output-240-120v-input/){target=_blank}, which feeds directly into the battery bank.

    Then, the 12kw [sol-ark 12k](https://www.sol-ark.com/residential/12k-essentials-inverter/){target=_blank} produces clean pure sine wave power from the provided DC.

Before- we move to the server rack- there is one other thing to note-

[Multiple forms of surge protection are used](2024-09-15-Surge-Protection.md){target=_blank}.

### Server Rack Power

#### Diagram

With the mains power out of the way, lets dig into my miniature data center itself, starting with a diagram.

``` mermaid
flowchart LR
    Breaker
    Outlet
    UPS
    Surge["Inline Surge Arrestor"]

    subgraph rack["Server Rack"]
        PDU1
        PDU2
        ATS
        Servers
    end

    subgraph closet["Networking Closet"]
        WAN["WAN Router / Firewall"] --> UPS2
        LAN["LAN Router / Firewall"] --> UPS2
        POE["POE Switches"] --> UPS2
        UPS2["Small UPS"]
    end


    Servers --> PDU1 & PDU2
    PDU1 & PDU2 --> ATS
    ATS --> | UPS Inline| UPS
    ATS --> | UPS Out of line | Surge
    UPS --> Surge
    Outlet --> Breaker
    UPS2 --> Surge
    Surge --> Outlet
```

#### Networking Closet

One goal of mine, is to allow the house to resume "normal operation" even if my entire rack of servers is offline.

To do this, The main "LAN/WAN" is handled with low-power hardware.

1. Unifi UXG-Lite
    - **Link**: [Unifi](https://store.ui.com/us/en/products/uxg-lite){target=_blank}
    - This is the primary LAN/WAN Firewall/Router at the time of this post.
    - Very soon, a Mikrotik HEX Refresh will become the primary WAN Router/Firewall, leaving the Unifi for LAN duties.
    - **Consumption**: MAX 3.8 watts
2. 2x Unifi USW-Lite-8-POE
    - **Link**: [Unifi](https://store.ui.com/us/en/category/switching-utility/products/usw-lite-8-poe){target=_blank}
    - One of these powers a pair of access points, as well as a pair of [usw-flex](https://store.ui.com/us/en/category/switching-utility/products/usw-flex){target=_blank} switches located in the living room, and garage.
    - The other, powers all of my POE security cameras.
    - **Consumption**: MAX 8w (Excluding POE Consumption)
    - Note- If the [USW-Ultra](https://store.ui.com/us/en/category/switching-utility/collections/pro-ultra/products/usw-ultra){target=_blank} existed when I installed these... there wouldn't be two POE switches.
        - I will note, I did attempt to run a [TPLink TL-SG1005P](https://amzn.to/4fqWUyV){target=_blank}[^amazon] for my POE cameras. However- it caused them to frequently crash. 

These devices are powered with a small, dedicated cyber power UPS unit. In the event of catastrophic failure, loss of solar, generator, and battery- This would keep the primary LAN/WAN online, along with the security cameras.

#### Server Rack

On the rear of the server rack, I have the incoming power supply.

![Image showing both PDUs, and the ATS mounted at the rear of my rack](./assets-2024-lab/power-rack.webP)

I have a pair of vertiv rPDUs to distribute power to my servers. These are 120v PDUs, with individually switched AND metered outlets. These units also cluster together.

I did a full write-up of the capabilities here: [Vertiv rPDU](2024-08-09-vertiv-giest-pdu.md){target=_blank}

Overall- these units have been OUTSTANDING. I am- still working on creating a MQTT-based integration which connects them to both [home assistant](https://www.home-assistant.io/){target=_blank}, and [emoncms.](https://emoncms.org/){target=_blank}

If- you are interested in this- [please checkout rPDU2MQTT on GitHub](https://github.com/XtremeOwnage/rPDU2MQTT){target=_blank}.

I do this- because I like to be able to visualize every single watt which travels through my house.

This is an older picture, and far more monitoring has been added since. Nearly every light fixture, every device. There are very few things I don't have monitored now for the entire house.

![Image showing a sankey diagram, with all of my loads displayed](../../Home-Automation/2023/assets-energy-flow/energy-usage-sankey-earlier.webP)

I do have a related post for [Building energy flow diagram in home assistant](../../Home-Automation/2023/home-assistant-energy-flow-diagram.md){target=_blank}

??? note "Why emoncms"
    I do often get asked why I use Emoncms, when Home Assistant exists, Influx, Prometheus, etc...

    The reason is- Its STUPID simple, and reliable. It does one thing. It collects and stores data.

    Not- in a database, but, in a simple flat-file format, where YEARS of energy data at a 15 second interval, only takes up a few kilobytes.

    The simplicity is key here. I need it to be as reliable as possible. And- it achieves this.

    Home assistant, occasionally has an update, which will rename entities, causing the energy data to break. As well, occasionally, something will happen, which just destroys its energy diagrams. 

    I have 4 years of data in emoncms. If something is not reporting in data, it will let me know. Things do NOT change in here, without me explicitly changing them.

    So, TLDR; Its all about consistency, and reliability. Ecmoncms can run on a potato, and has zero external dependencies.


## Networking

I have a reasonably complex network setup, involving multiple routers, firewalls, switches etc.

![This is a picture of the front of my rack, with the networking hardware circled](./assets-2024-lab/networking-circled.webP)

Not Displayed- The closet where my rack resides, also contains.. a few switches, and other small hardware.

!!! note
    As a note, this post is being written in parallel with [my 2024 Network Refresh](./2024-11-23-Network-Refresh.md){target=_blank}. 
    
    I am documenting this in the state it was before that project, since that project will not be fully implemented this year.

First- I will break this into the hardware used, and then explain routing, topologies, etc.

### Networking - Hardware

In the current state, My entire network consists of Unifi gear, and Mikrotik gear.

Unifi gear, is fantastic at making a single plane of glass. 

It is absolutely horrible, if you want to use layer 3 switches. [Post: Why you shouldn't buy a L3 Unifi Switch](./2024-07-15-Unifi-Layer-3.md){target=_blank}

Also, "POE" and "10G", results in the same switch costing twice as much.

As such, my lab is slowly transitioning away from Unifi, to contain more Mikrotik gear.

I have no plans on completely moving away, but, instead wish to use the best piece of gear, where it makes sense.

Ie- Unifi is extremely good at managing "LAN" subnets, and clients.

Mikrotik, is extremely capable in terms of features, and its layer 3 routers, work exactly as one would expect.

Also- When debugging- EVERYTHING on the Mikrotik is in real time. Debugging on Unifi can be a huge pain.

???+ "Unifi Hardware"

    1. **Unifi: UXG-Lite**: 
        - Primary WAN Firewall/Router.
        - Primary LAN Router.
        - Links
            - [Unifi](https://store.ui.com/us/en/products/uxg-lite){target=_blank}
            - [Amazon](https://www.amazon.com/dp/B0CW2DZZ3Z){target=_blank}[^noamazon]
    2. **Unifi: USW-Pro-24**:
        - Horrible excuse for a "Layer 3" switch. [Post: Why you shouldn't buy a L3 Unifi Switch](./2024-07-15-Unifi-Layer-3.md){target=_blank}
        - Primary 1G switch for server rack.
        - Links
            - [Unifi](https://store.ui.com/us/en/products/USW-Pro-24){target=_blank}
            - [Amazon](https://amzn.to/41NVR8Y){target=_blank}[^amazon]
    3. **Unifi: USW-Aggregation**:
        - Primary 10G Switch, for Server rack.
        - Links
            - [Unifi](https://store.ui.com/us/en/products/usw-aggregation){target=_blank}
            - [Amazon](https://amzn.to/40cY6S0){target=_blank}[^amazon]
    4. **Unifi: UAP-AC-Pro**:
        - Wireless Access Point
        - Links
            - [Unifi](https://store.ui.com/us/en/products/uap-ac-pro){target=_blank}
            - [Amazon](https://amzn.to/4gzSJSw0){target=_blank}[^amazon]
    4. **Unifi: U6 Pro**:
        - Wireless Access Point
        - Links
            - [Unifi](https://store.ui.com/us/en/products/u6-pro){target=_blank}
            - [Amazon](https://amzn.to/3DxGV4K){target=_blank}[^amazon]
    4. 3x **Unifi: USW-Flex-Mini**:
        - I have these scattered around. One in the garage, one in the livingroom. etc.
        - POE-powered layer 2 switches. Not many features, but, for 29$ each- they do EXACTLY what I need them to do.
        - Links
            - [Unifi](https://store.ui.com/us/en/products/usw-flex-mini){target=_blank}
    5. 2x **Unifi: USW Lite 8 POE**:
        - When I picked up all of my gear, Unifi didn't have a cost-effective POE switch, such as the [USW-Ultra](https://store.ui.com/us/en/category/switching-utility/collections/pro-ultra)
        - So... I have a pair of these.
        - Links
            - [Unifi](https://store.ui.com/us/en/products/usw-lite-8-poe){target=_blank}
            - [Amazon](https://amzn.to/3PfjMGM){target=_blank}[^amazon]
    6. **Ubiquity EdgeMAX / EdgeRouter**:
        - This has been in my home for over a decade. It was my primary router/firewall for most of the last decade. It serves live as my IOT/Security firewall these days.
        - Links
            - [Unifi](https://store.ui.com/us/en/category/wired-edge-max-routing/products/er-x){target=_blank}
            - Not- the same model. Also, out of stock.

???+ "Mikrotik Hardware"

    1. **Mikrotik: CRS504-4XQ**:
        - This is the "CORE" L3 Router for my network, and handles routing for all of my 10G, 25G, and 100G links.
        - I love this switch. Just saying.
        - Links
            - [Mikrotik](https://mikrotik.com/product/crs504_4xq_in){target=_blank}
            - [ServeTheHome](https://www.servethehome.com/mikrotik-crs504-4xq-in-review-momentus-4x-100gbe-and-25gbe-desktop-switch-marvell/){target=_blank}
            - [Amazon](https://amzn.to/41WmFUv){target=_blank}[^amazon]
    2. **Mikrotik: CSS610-8G-2S+**:
        - The switch in my office. 
        - Its simple. Its stupid. It works.
        - Links
            - [Mikrotik](https://mikrotik.com/product/css610_8g_2s_in){target=_blank}
            - [ServeTheHome](https://www.servethehome.com/mikrotik-css610-8g-2sin-review-10gbe/){target=_blank}
            - [Amazon](https://amzn.to/4gWSmBv){target=_blank}[^amazon]
    3. **Mikrotik: hEX Refresh**:
        - This- will soon be the primary WAN firewall. Until then though- it exists.
            - See [2024 Network Refresh](./2024-11-23-Network-Refresh.md){target=_blank}
        - Note- this was released VERY recently. If you want one- don't accidentally order one of the older versions.
        - Make sure you are getting the EU50G. Its significantly faster then the other hEX variants.... for the same price.
        - Links
            - [Mikrotik](https://mikrotik.com/product/hex_2024){target=_blank}
            - [Amazon](https://amzn.to/4gPdOrU){target=_blank}[^amazon]

### Networking - Diagrams

#### Logical Diagram

Here is my logical routing diagram.

!!! info
    Note- IP Subnets, VLAN Identifiers, and ASNs have been randomized.

    Subnet Masks remain the same.

Note, All routers propagate routing information using OSPF. The UXG, EdgeRouter, and Mikrotik all have direct access to each other.

``` mermaid
flowchart TB
    subgraph OUTER
        WAN 
    end

    WAN--> | PPPoe| UXG


    subgraph BGP["Core 172.16.1.0/24 (OSPF)"]
        UXG["Unifi UXG-Lite <br />172.16.1.1"]
        EDGEMAX["EdgeRouter <br />172.16.1.3"]        
        100G["Mikrotik 100G <br />172.16.1.4"]
    end

    100G --> TRUSTED
    100G --> LAN2
    EDGEMAX --> SECURE
    UXG --> LAN


    subgraph TRUSTED["Servers 192.168.10.0/22"]
        direction LR
        V_Server["V_Server  <br />vlan 14<br />192.168.10.0/24"]
        V_Kubernetes["V_Kubernetes  <br />vlan 18<br />192.168.11.0/24"]
        V_RKE["V_RKE  <br />vlan 22<br />192.168.13.0/24"]
    end

    subgraph SECURE["SECURE 192.168.20.0/22"]
        direction LR
        V_MGMT["V_MGMT <br />vlan 50<br />192.168.20.0/24"]   
        V_SECURE["V_SECURE  <br />vlan 25<br />192.168.21.0/24"]   
        V_IOT["V_IOT <br />vlan 30<br />192.168.22.0/24"]  
    end

    subgraph LAN2["Internal 10.10.128.0/18"]
        direction LR
        V_LAN_10G["V_LAN_10G <br />vlan 75<br />10.10.128.0/24"]
    end
    
    subgraph LAN["LAN 10.20.0.0/16"]
        direction LR
        V_LAN["V_LAN <br />10.20.1.0/24"]
        V_LAN_Isolated["V_LAN_Isolated <br />10.20.2.0/24"]
    end
```

#### Physical Diagram

``` mermaid
flowchart LR
    subgraph Office
        WAN --> |GPON| MC["Media Converter"]
        OfficeSwitch["Mikrotik CSS610-8G-2S"]

        OfficeSwitch --> |10G DAC| PC1
        OfficeSwitch --> |1G| PC2 & PC3
        PC1["Gaming / Main PC"]
        PC2["Work PC"]
        PC3["Wife PC"]
    end

    MC --> |1G CAT6| USW1
    OfficeSwitch --> | 10G SM Fiber| AGG
    
    subgraph Closet
        USW1["Closet-Switch (Unifi USW Lite 8 POE)"]
        USW2["Security-Switch (Unifi USW Lite 8 POE)"]

        USW2 --> |CAT6 POE| Security["Security Cameras"]
        USW1 --> |CAT6 POE| LivingroomSwitch & GarageSwitch
        LivingroomSwitch["USW-Flex-Lite (Livingroom)"]   
        GarageSwitch["USW-Flex-Lite (Garage)"]

        USW1 --> |CAT6 POE| UAPACPRO & U6PRO
        UAPACPRO["Unifi: UAP-AC-PRO AP"]
        U6PRO["Unifi: U6 Pro AP"]
    end



    USW1 & USW2 --> |Bonded 1G| CORE
    subgraph Rack
        CORE["Unifi: USW-Pro-24"]
        AGG["Unifi: USW-Aggregation"]
        EDGE["Ubquiti: EdgeRouter 5"]
        100G["Mikrotik: CRS504-4XQ"]
        UXG["Unifi: UXG-Lite"]

        CORE <--> |10G MM| AGG <--> |10G MM| 100G <-.-> |"10G MM (STP Down)"| CORE
        CORE --> |2x 1G| EDGE & UXG

        100G --> |100G DAC| KUBE01["Optiplex 5070"]
        100G --> |100G DAC| KUBE02["Dell R730XD"]
        CORE --> |1G| KUBE04["Optiplex 3070m"]
        100G --> |100G DAC| KUBE05["Optiplex 5070"]
        CORE --> |1G| KUBE06["Optiplex 7050m"]
        CORE --> |2x 1G| NAS["Synology"]
    end
```

Sorry- the physical diagram is a hair messy.

A few notes-

1. My WAN enters through my office, where its GPON is converted to ethernet.
    - This feeds into a dedicated vlan on one of the switches in my closet.
    - The core switch then connects this vlan to the UXG-Lite. (a dedicated link exists for LAN traffic)
2. There is a redundant loop between the switches in my server rack. STP is used to ensure we don't have loops.
3. Not displayed- All of the 100G-connected servers also have a 10G failover link to the 10G switch.
4. The various routers all propage routing information using OSPF.

### Networking - Security / ACLs.

All WAN-related ACLs are currently handled by the UXG-Lite, including port forwarding.

All ACLs related to my IOT devices, and Security cameras, are handled by the Edgemax/EdgeRouter.

All ACLs related to my server, are handled directly inside of proxmox. Its built in firewall maangement, works great for what is needed.

Additional ACls are defined inside of my kubernetes cluster, where needed.

### Networking - Services

#### DHCP

DHCP is handled by...

1. UXG manages DHCP for its networks.
2. Technitium handles DHCP for the "LAN 10G" network, as well as all of the server/kubernetes subnets.
3. The Edgemax handles DHCP for its Security, Management, and IOT subnets.

#### DNS

DNS is handled by....

1. Technitium is my primary DNS server.
2. Unifi forwards DNS requests to it, for its subnets.
3. A BIND9 server, using zone transfers is the secondary DNS, and is capable of processing traffic in the event Techitum is down for maintenance.
4. EdgeMAX functions as a DNS forwarder server for its subnets
    - IOT Subnets do NOT have DNS. None. By design.

#### NTP

NTP is handled by my Proxmox servers. 

An ansible playbook automatially provisions Chrony, running as a time server, and autoamtially adds them to an internal NTP pool.

All other servers, networking devices are configured to use this internal pool.

## Issues / Complaints

#### Ceph

Ceph, is a love and hate relationship for me.

As I said above- its EXTREMELY flexible, and very reliable.

However- I get a FRACTION of the IOPs out of it, as I have put into it.

I have been keeping my eye out for anything which can offer the same level of integration, but, with vastly improved performance.

#### LAN Seperation

My big project this year, is the [Networking Revamp](./2024-11-23-Network-Refresh.md){target=_blank}. 

Reason being- I want what I do in my lab, to not affect the LAN at all. 

Meaning- if I go yank the power cord for all of my servers- my wife shouldn't notice a thing, at least, in terms of the internet.

So- the goal is to move the entire LAN-area of the network, outside of my server rack.

#### Unifi Gateway

My biggest complaint here, there is no "native/builtin" support in Unifi for handling my IPv6 GIF tunnels.

Without that support- I don't have working IPv6 WAN. That- will be fixed soon though, when the Mikrotik hEX replaces the Unifi as the primary WAN router.

## Rack Organization

This section is soley dedicated to links of products used in my rack. Think.... Cable management, Brackets, etc.

There is nothing technical documented in this section, its all just product links.

### Rack Hardware 

#### Rack Itself

The rack itself, is a Startech 4-Post 25U Rack.

- [Amazon: Startec 4U 24U Rack](https://amzn.to/49ZPstx){target=_blank}[^amazon]

#### Front of Rack

![Picture show all organizational elements of the front of the rack, circled](./assets-2024-lab/rack-front-organizational-features.webP)

???+ info "#1 - Startech 2U Finger Duct"
    - [Amazon: Startech 2U Finger Duct](https://amzn.to/4fEwBoI){target=_blank}[^amazon]

    Having previously used patch panels, with keystones, and other options- this is my favorite option so far.

    Not- because its used to hide a mess of wires....

    ![Image showing clean, organized cables behind the fingers tray](./assets-2024-lab/finger-tray.webP)

    But- because its extremely easy to maintain.

    Keystone panels look nice, but, can be a challenge to maintain. Especially- if you color code them like my old panel. 

???+ info "#2 - (NoName) 1U Blanks"
    - [Amazon: 1U Blanks - 5 Pack](https://amzn.to/4fDj4y2){target=_blank}[^amazon]

    Blanks are seriously the difference between an "OK" looking rack, and a "Great" looking rack.

    A 5-pack of no-name 1U blanks did the job for me.

???+ info "#3 - Startech 2U Shelf"
    - [Amazon: Startech 2U Shelf](https://amzn.to/4gMy11O){target=_blank}[^amazon]
    
    A simple shelf on my rack is used to hold the Optiplex SFFs, and my Synology.

    As a note, it sags when loaded with all of the hardware I have on top of it. 

    The below disk shelf provides verticle support & stability. It has full-depth rails.
???+ info "#4 - (NoName) 1U Brush Panel"
    - [Amazon: 1U Brush Panel](https://amzn.to/41Wlx3q){target=_blank}[^amazon]
    
    So, the challenge for this particular location was handling the passthrough of not only the massive, fat 100GBe DACs.... But the front-positioned power cables from the CRS504.

    I settled for using a simple brush panel. 

#### Rear of Rack - Top

![Image showing the Top-Rear of the rack, with rack-hardware annotated](./assets-2024-lab/rack-rear-annotated.webP)

???+ info "#1 - Cable Matters 1U Keystone Panel"
    - [Amazon: Cable Matters 1U Keystone Panel](https://amzn.to/4gwF4f2){target=_blank}[^amazon]

    Nothing much to say here- But, Cable matters does produce a solid panel.

    As a bonus, it has "hooks" for cable ties, or velcro.

    In the future, I will be mounting one of these inside of the closet itself, to help cleanup and terminate the incoming cables.

???+ info "#2 - (NoName) 4U Wall Mount"
    For everyone who has read this far- I'm going to assume this is the part you are interested in.

    How did you verticle mount the PDUs and ATS.

    WELL, the solution, was actually extremely simple. A simple wall-mount.

    - [Amazon: 19 Inch 4U Heavy Duty Vertical Wall Mountable Rack](https://amzn.to/41UoAJp){target=_blank}[^amazon]

    Seriously, thats it. Its attached using standard cage-nuts, and a few 3/4" washers.

    ??? note "A bit more history (Click to expand, if interested)"
        This- is actually the 2nd attempt at verticle mount.

        ![Image showing the original 4U verticle rear-mount](./assets-2024-lab/rack-rear-verticle-original.webP)

        Originally, I used a [Amazon: Startech 2U Wall-Mount Shelf](https://amzn.to/4fIGG46){target=_blank}[^amazon], with [Amazon: Startech 2U 4in spacers](https://amzn.to/3Dy5mz9){target=_blank}[^amazon] to help "distance" the shelf from the rack.

        Since- the shelf was not intended to be rack-mounted, I did need to drill out holes which aligned to standard cage nut spacing.

        The issue I encountered- my PDUs are not 1U. They are 1.5U, which caused issues when I tried to add an ATS, as seen above.

        When I decided to pick up a 2nd vertiv PDU, I went ahead and swapped to the 4U rack instead.

        I mounted it flush to the rack-rails as the new unit had the correct width, and had correctly spaced holes which aligned to cage nuts.

        The original 2U unit, required drilling out holes which aligned with my cage-nuts.

#### Rear of Rack - Middle (Power cable organization)

On the rear of the rack- hopefully you have noticed the effort I put into cable managment here!

![Image showing the rear of the rack, with the fingers trays circled in red](./assets-2024-lab/power-cables-1.webP)

The solution used here, is just a **PAIR** of no-name fingers trays.

???+ note "Why"
    Honestly, after spending all of the time and effort cleaning up the front of the rack, I really wanted to try and make the rear pretty as well.

    Verticle PDUs for 24U racks are pretty hard to come by. And if you want both switched AND individually metered- its extremely difficult to find in a price that I was willing to pay.

    So- I needed a good way to help organize and clean up the wires, a set of fingers trays- did the job fantastically, with a little help from some velcro.

PAIR- is bolded, as this is literally a pair of finger trys, with a spacer.

![Image showing the finger trays screwed togather, inside of the aforementioned startech 2U spacer](./assets-2024-lab/power-cables-2.webP)

Remember.... the spacer that was originally used for holding the verticle shelf containing the PDUs? Well- it lives here now.

Products-

- [Amazon: 2 Pack 1U Finger Duct](https://amzn.to/3DxZPIC){target=_blank}[^amazon]
- [Amazon: Startech 2U 4in spacers](https://amzn.to/3Dy5mz9){target=_blank}[^amazon]

The particular "qiaoyoubang" 1u ducts used- are actually extremely solid, stamped steel construction.

I chose these particular units, due to the large openings between the fingers, which is plenty of room for power cables to fit without rubbing.

Here is one final picture showing the top of the cable trays, which was taken before I acquired a 2nd PDU.

![Image showing the finger trays holding power cables](./assets-2024-lab/power-cables-3.webP)

Overall- I am extremely happy with how this turned out.

### Cables

#### "Thin" ethernet
One factor which really helped cleanup the mess of wires going through my rack- was just by using thinner cables.

* [Amazon: Monoprice Cat6A 5ft 10-pack](https://amzn.to/3W2wJaH){target=_blank}[^amazon]
* [Amazon: Monoprice Cat6A 3ft 10-pack](https://amzn.to/4fHp7l3){target=_blank}[^amazon]
* [Amazon: Monoprice Cat6A 1ft 10-pack](https://amzn.to/3VZEqP2){target=_blank}[^amazon]

So- the first thing I will note- these DO work for both POE, and for 10G.

The cables, also come in different color combinations.

I have been using these cables for years, and I am a huge fan of them.

![Image showing multiple monoprice orders in my cart](./assets-2024-lab/monoprice-slim-orders.webP)

When I redid all of the cable management this year, I replaced all of the remaining standard CAT6 with these slim cables.

#### Fiber

For my fiber- I have a few different sources.

* [Amazon: 6-Pack 1ft OM3](https://amzn.to/40izDK3){target=_blank}[^amazon]

You can see ONE of these used to link between my USW-PRO-24 and my USW-Aggregation

* [FS.com: 66ft OS2](https://www.fs.com/products/40205.html){target=_blank}[^noaff]

I am using two runs of this fiber to link between my server closet, and my office. This is the yellow fiber you see running through the rack.

It is single-mode fiber, running at 10G.

* [FS.com: 5ft OM4](https://www.fs.com/products/88534.html){target=_blank}[^noaff]
* [FS.com: 3ft OM4](https://www.fs.com/products/40180.html){target=_blank}[^noaff]

I am using multi-mode patch cables from fs.com. 

These are used to connect the 10G switch, to my individual servers. (Note- Failover link only! 100G link is the primary)

These are the blue runs of fiber you see running through the rack.

#### Fiber Modules

I use fs.com modules exclusively for my fiber connections.

* [FS.com: UF-MM-10G (Unifi 10G Multimode)](https://www.fs.com/products/65336.html){target=_blank}[^noaff]
* [FS.com: 10G-SFPP-SR (Brocade 10G Multimode)](https://www.fs.com/products/31443.html){target=_blank}[^noaff]
* [FS.com: MFM1T02A-SR (Mellanox 10G Multimode)](https://www.fs.com/products/65334.html){target=_blank}[^noaff]
* [FS.com: SFP-10G-LR-I (Cisco 10G Singlemode)](https://www.fs.com/products/111897.html){target=_blank}[^noaff]

Honestly, I have a combination of these modules, with Brocade, Cisco, and Unifi compatible.

I really have not had any compatability issues between these modules, and any of the switches I have, regardless of if they are mismatched.

#### DACs

For 10G DACs, I honestly usually just buy whatever is the cheapest on eBay.

I DO have a handful of legitimate cisco twinax cables, which are fanstatic. But- I have never had any issue with buying cheap DACs from eBay.

For the 100G DACs, I am using [FS.com: 1.5m 100G Twinax](https://www.fs.com/products/116122.html){target=_blank}[^noaff].

However, I actually purchased these cables from here: [eBay: FS 100G DAC 116122](https://ebay.us/8x2IOP){target=_blank}[^ebay]. (13$ less. Came brand-new in original packaging too)

#### SAS

For SAS cables, I am using [Amazon: Monoprice 2 Meter SFF-8088](https://amzn.to/4fyBtMg){target=_blank}[^amazon]


### Misc Organization

#### Velcro Strips

* [Amazon: 120pcs Velcro](https://amzn.to/4gUHNPo){target=_blank}[^amazon]

I have found these off-brand/no-name velro strips to be extremely handy when doing cable management.

If- you use zip-ties, I'd recommend you give these a try. For the 5$ it currently costs, you can't go wrong.

There is no a single zip-tie in my rack, that I am currently aware of- I replaced all of them with these velcro strips.

I use these same strips all over my house, my office, anywhere I need to organize cables togather.

* [Amazon: Self-Adhesive Cable Clips](https://amzn.to/420nADD){target=_blank}[^amazon]

While not visible- I use these cable clips inside of the rails of my rack to hold fiber, and ethernet in place.

Don't- put these on your wall. They will damage the wall when you try to remove them.

But- these are a simple item I have found to be quite effective for doing cable management.

Note- Not suitable for power cables- only thinner cables.



## Footnotes, Disclaimers, etc...

### Disclaimers

--8<--- "docs/snippets/non-sponsored.md"

--8<--- "docs/snippets/affiliate.md"

### Footnotes

[^ebay]:
    --8<--- "docs/snippets/ebay-affiliate.md"
[^amazon]:
    --8<--- "docs/snippets/amazon-affiliate.md"
[^noamazon]:
    This is a non-affiliated Amazon link.
[^noaff]:
    Non-affiliated