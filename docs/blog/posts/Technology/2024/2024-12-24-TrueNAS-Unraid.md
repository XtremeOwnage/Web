---
title: "My history with Unraid"
date: 2024-12-25
tags:
- Homelab
- Homelab/TrueNAS
- Homelab/Unraid

---

# My history with Unraid & TrueNAS

I have swapped between Unraid, and TrueNAS a few times over the years.

Often, I stumble upon threads asking... Should I use Unraid? SHould I use TrueNAS?? Which one?!?

Well- I'm not going to tell you which one to use. Rather- I will give you the reason I personally use Unraid.

<!-- more -->

## A short history

I have flipped back and forth between Unraid, and TrueNAS for years.

I started using FreeNAS back in 2014, long before it was known as TrueNAS.

In 2020, When COVID hit, I [built a 500$ server](https://xtremeownage.com/2020/07/24/closet-mini-server-build/){target=_blank}, which ran Unraid. Unraid was easy, Unraid was effective.

But- I was not very happy with the performance of Unraid's array.

When TrueNAS Scale dropped, with built-in docker, I switched to it chasing after improved storage performance. 

And- it delivered. My [40G NAS Project](../../../../pages/Projects/40G-NAS.md){target=_blank} basically started life after I switched to TrueNAS Scale.

I also- wrote a comparison post back then, after switching: [Unraid Vs TrueNAS SCALE 2021](../2021/unraid-vs-truenas-scale.md){target=_blank}

Eventually- TrueNAS started being a pain in the rear...... causing blog posts such as...

1. [TrueNAS Scale - How to use vanilla docker](../2021/2021-12-15-Truenas-Vanilla-Docker.md){target=_blank}
    - Because, using vanilla docker without using the built in kubernetes, took manual steps.
2. [TrueNAS Scale - Re-enable Apt-get](../2022/2022-03-26-TrueNAS-Reenable-apt-get.md){target=_blank}
    - Because someone at IX-Systems said, Hey, Before we ship this image, run `chmod -x /bin/apt*`
3. [TrueNAS Scale - VMs cannot access host](../2022/2022-10-28-TrueNAS-VM-Host-Network.md){target=_blank}

And, while checking my news feed one day, I noticed Unraid had dropped a new version 7 beta.

[Unraid: 7.0.0 Release Notes](https://docs.unraid.net/unraid-os/release-notes/7.0.0/){target=_blank}

The feature which caught my eye- NATIVE ZFS Pools.

I installed the beta, and switched everything over the next day.

I have honestly been here every since. Since, the 40G NAS Project is effectively dead, and no longer used or needed- Unraid honestly, suits my needs very well.

I will, quickly touch base on a few features....

### Features / Functionality between Unraid, and TrueNAS Scale

So first- lets get some misconceptions out of the way.

Both Unraid and TrueNAS Scale, use the exact same OpenZFS, and the exact same KVM/QEMU. This means- they have the exact same capabilities.

The only differences are the user interfaces, and, there are some notable differences.

TrueNAS Pros:

1. Snapshot management built in, without using a 3rd party plugin. (But, you can easily add sanoid/syncoid to unraid.)
2. No FUSE. Its lightning fast. ([Unraid 6.12](https://docs.unraid.net/unraid-os/release-notes/6.12.0/#exclusive-shares){target=_blank} added "Exclusive Shares", which mitigates this issue for exclusive pools.)
3. ZVol / iSCSI Management, Built In. (Unraid has plugins which can add iSCSI, but, its not native.) TrueNAS makes it effortless to provision a zvol, and attach to a server. Unraid can do it..... via the OpenZFS CLI.

Unraid Pros:

1. The core product has not experienced any massive, breaking changes. (Scale, has underwent multiple MASSIVE changes to how "apps" are handled.)
2. The GUI is beautiful. Its simple. And its effective.
3. Has honestly, one of the nicest user interfaces for hardware passthrough to VMs.
4. Flexibility
    - It can do XFS, ReiserFS, ZFS, or BTRFS. Unraid **ONLY** does ZFS.
    - In addition, It has the "Unraid Array", its special thing.
5. Power Efficiency
    - Unraid's built in array, is the most power efficient option, for write-once, read-many. See [Power Efficient Storage](#power-efficient-storage)
6. A nice app store. (Use both- and you will know what I mean)
7. ACLs that aren't a PITA. [Google: "Reddit TrueNAS ACLs"](https://www.google.com/search?q=reddit+truenas+ACLs){target=_blank}
    - Seriously- Unraid's ACLs are very, very easy. They just work. TrueNAS- takes a bit more effort.
    - TrueNAS hands down has much more powerful ACLs, but- for most home uses- the simple ACLs used by Unraid, is PERFECTLY acceptable.
    - Think about it- how many of our labs have more then a single user?
8. Need more storage? Add a disk. 
    - Size does not need to match. As long as the parity disk is equal or larger in size, you can expand the array.


### Power Efficient Storage

One of the biggest reasons I use Unraid, is for energy consumption reductions.

ZFS, requires all of the disks in its array to be spinning, in order to read, or write any contents.

Ceph, I don't even think it supports disks sleeping.

Unraid's "Array", is not raid. It stores files, on individual disks, and calculates parity on a dedicated parity drive.

So, say, you use Unraid to store your archive of Linux ISOs. And- you need to access a debian ISO from 2011.

Well, only the drive containing that ISO would need to spin up, in order to read the data. You can have an array with 32 disks, that only needs to spin up a single drive.

This is **FANTASTIC** for building a media server.

Even writes- don't need to spin up the disks. Instead- Unraid offers a cache pool. New data gets stored here. And, eventually the data gets flushed to the main array where it will need to spin up all of the disks, calculate parity, etc.

BUT- you can tune the cache to only do this a few times a day, or better- only do when the cache pool is near full. 

Doing this- my drives spend 99% of the time asleep, saving dozens of watts of consumption.

### "Apps" are just normal docker.

Remember the links above to things such as IX blocking built-in docker, removing apt-get, changing how apps are handled?

Well, Unraid is NOTHING more then vanilla docker. Its even easier to use then portainer.

You can use docker-compose files. The user interface will even show your stacks.

You can use docker CLI. And it will work with the user interface.

You can use the apps catalog. You can build your own apps. 

Its nothing but **VANILLA** docker. There is nothing that stops you, from managing your containers, on your hardware, how **YOU** want to manage them.

Seriously- I am going to rant about this. IX-Systems for SOME REASON thought I shouldn't be able to use the distribution how I want to use it. If I want to shoot myself in the foot- then let me shoot myself in the foot. I want to control MY hardware, the way I want to control my hardware.

So, massive win, for just having a nice interface around a widely used service.

### Interface

I personally love the unraid interface. The dashboard, contains all of the information you need to see at a glance.

Its extensible. You can find plugins to display whatever you want to see.

Its easy to make VMs. Its easy to make containers. Its easy to add shares.

## Summary

A very short post- Originally this content was apart of [2024 Homelab Summary](./homelab-2024.md){target=_blank}, However, I broke it out to have its own post.