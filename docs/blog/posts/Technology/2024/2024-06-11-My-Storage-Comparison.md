---
title: "Exploring My Storage Solutions: Pros and Cons"
date: 2024-06-11
tags:
  - Homelab
  - Proxmox
  - Ceph
  - Storage
---

# Exploring My Storage Solutions: Pros and Cons

As someone who's been hands-on with various storage solutions, I want to share my experience and insights. Here's a breakdown of the different options I use, the benefits, and the drawbacks of each.

The various solutions I have used over the last 15 years includes...

* Windows Storage Spaces (Late 2013)
* Linux - Manual (Early 2014)
* LSI Megaraid HW Raid (2014)
* TrueNAS Core (Late 2014-2019)
* Unraid (Mid 2020)
* TrueNAS Scale (2021)
* Longhorn (2023)
* Ceph (2023)
* Synology (2024)

And- I am going to summarize my thoughts and options on each and every one of these.

<!-- more -->



## Capabilities matrix

### Sharing services and protocols

A quick comparisons of which sharing protocols, are available for each NAS solution.

☑️ = Works out of the box
➕ = Can be easily installed, and enabled
❌ = Not available directly.

| Storage Solution | NFS    | Samba/CIFS | S3     | iSCSI    |
|------------------|--------|------------|--------|----------|
| DIY Linux NAS    | ➕[^3] | ➕[^3]    | ➕[^3] | ➕[^3]  |
| DIY Windows NAS  | ➕[^4] | ☑️        | ➕[^5] | ➕[^6]  |
| Synology NAS     | ☑️     | ☑️        | ➕[^1] | ☑️      |
| Unraid           | ☑️     | ☑️        | ➕[^1] | ➕[^2]  |
| Ceph             | ☑️     | ❌        | ☑️     | ☑️      |
| TrueNAS Scale    | ☑️     | ☑️        | ➕[^1] | ☑️      |
| TrueNAS Core     | ☑️     | ☑️        | ➕[^1] | ☑️      |

[^1]: Requires installing MinIO via container, LXC, jail, etc.
[^2]: Requires installing the iSCSI Target plugin.
[^3]: Requires manual installation and configuration
[^4]: Requires windows server & [Server for NFS Role](https://learn.microsoft.com/en-us/windows-server/storage/nfs/deploy-nfs){target=_blank}
[^5]: Requires installing [Minio on windows](https://min.io/docs/minio/windows/index.html){target=_blank}
[^6]: Requires windows server & [iSCSI Target Server Role](https://learn.microsoft.com/en-us/windows-server/storage/iscsi/iscsi-target-server){target=_blank}

### File System Support

☑️ = Native, out of the box
➕ = Can be installed, and enabled
❌ = Not available directly.

| Storage Solution | ZFS    | BTRFS      | XFS | ext4  | NTFS     | REFS  |
|------------------|--------|------------|-----|------ |----------|-------|
| DIY Linux NAS    | ➕     | ➕        | ☑️  |  ☑️  | ☑️      |  ➕   |
| DIY Windows NAS  | ❌[^11]| ❌        | ❌  |  ❌  | ☑️      |  ☑️   |
| Synology NAS     | ❌     | ☑️        | ❌  |  ☑️  | ❌      |  ❌   |
| Unraid           | ☑️     | ☑️        | ☑️  |  ❌  | ❌      |  ❌   |         
| TrueNAS Scale    | ☑️     | ❌        | ❌  |  ❌  | ❌      |  ❌   |
| TrueNAS Core     | ☑️     | ❌        | ❌  |  ❌  | ❌      |  ❌   |

[^10]: Note- ceph is not included in this chart, as, its not really applicable.
[^11]: There are 3rd party ports of ZFS to windows, however, this is not official projects


## Raid-Implementations (Not specifically NAS)

### Windows Storage Spaces

!!! info
    Although, this is not technically a NAS- I am including it just to share my experiences. 

    But- adding the windows file sharing role, would create a NAS from it.

In 2013 when I started running my FIRST server, it was running windows using parity storage spaces.

At the time, parity, well. It didn't perform very well. With a pool of 4 2TB disks- the performance was just horrible, and completely unsuitable for... downloading and managing ISOs.

You would have to schedule the downloads for a while- with a pause so that the extracts could run. And- if you didn't throttle the operations- anything else trying to also use the drive (streaming, etc...) would also break.

I hear, it has gotten slightly better- but, I still would never recommend this option.

#### Pros

Easy to use

Built into windows. Everyone has access to it.

#### Cons

Poor performance, Poor IOPs.

Not very flexible.

#### When would I recommend this?

The ONLY time I would recommend this, is for very basic use-cases, where performance isn't a concern, and you just need a redundant array of disks, on a windows server or workstation.

For that use-case, its hard to beat. Anyone can configure it, even without any experience in IT.

### Hardware Raid

!!! info
    Although, this is not technically a NAS- I am including it just to share my experiences. 

    But- this can be easily consumed by a NAS, just by installing an OS with file/block/object sharing capabilities.

After experiencing numerous issues, and headaches with windows storage spaces, I picked up a LSI Megaraid card, with 512m onboard cache.

This drastically boosted performance to a point where my 4 HDDs could compete with the performance of a cheap SSD.

#### Pros

Very fast

When it works, its invisible. (aka, you configure it, and then you forget about it)

#### Cons

Management can be a pain. Depending on what you need to do, you might need to reboot the PC and access the boot-rom to make changes.

There is a utility which runs on the OS, that provides some information, and configuration.

#### When would I recommend using this?

If you want a redundant array of disks, and you want as little management as possible over it.

This- is a solution, you install, you configure it, and then you forget about it.



## General Purpose NAS  (Aka, an solution that works as a NAS out of the box)

### TrueNAS (Scale, and Core)

#### Brief History

TrueNAS Core- refers to what was originally called "FreeNAS" years ago. Since the introduction of TrueNAS Scale (Linux based), FreeNAS/TrueNAS was rebranded into (TrueNAS Core), which is BSD based. 

TrueNAS (Both scale and core) leverage ZFS, and ONLY ZFS.

TrueNAS Core, is based on BSD, TrueNAS Scale is based on Linux (debian, specifically)

TrueNAS Core, runs its apps in jails. 

TrueNAS Scale, uses its own implementation of kubernetes for running apps, with its own [TrueNAS CSI](https://github.com/terricain/truenas-scale-csi){target=_blank}

#### My History

Around 2014-2015, I needed to acquire a new server, and I needed around 12-16TB of overall storage. 

I ended up picking up a old precision tower, something like a T3500. It had 4 internal 3.5" bays, and I installed a 4-bay hot-swappable enclosure into the 3x 5.25" bays in the front, giving the room to old, 8x 2TB HDDs.

While- the server itself was a turd, with power-sucking quad core xeons, FBDimms eating 10 watts of energy each.... TrueNAS performed fantastically. It was able to effortlessly rebuild failed drives, it was reliable, and it performed extremely well.

As well- the built in jail support, enabled me to run all of the applications and services I needed. 

And- again, between 2021-2023, I used TrueNAS Core some more.

This was a major piece of my [40GB NAS Project](./../../../../pages/Projects/40G-NAS.md){target=_blank}

If you give TrueNAS core the proper hardware, and recommended amount of memory- Its performance is unbeatable. (There is no other solution on my list, that can easily bottleneck a 40gigabit ethernet link, without breaking a sweat)

Core, does offer better performance then Scale, from my experiences. However, Scale is more flexible on hardware, and has its own advantages. 

#### Capabilities

File Sharing via NFS, and CIFS are supported, with ACLs.

iSCSI 

You can run custom apps via Jails (Core), or Kubernetes/Docker (Scale)

You can host VMs, provided by QEMU.

Does have built in automatic snapshot management, and retention.

Has built in replication.

#### Pros

Performance. With the correct resources, this is the fastest NAS I have touched. Bar none. I was able to nearly effortlessly saturate 40 gigabits of ethernet.

Data integrity. Since it uses ZFS- ZFS is the goto file system I use, when I want to keep my data safe and protected. It offers built in integrity, rebuilding, and bit-rot protection.

Once you have it correctly setup, you can basically forget about it. 

#### Cons

ONLY supports ZFS.

Provided as an "appliance" (Despite- being based on debian). ix even goes as far as removing the execute flag from apt-get. [Although, you can re-enable this.](./../2022/2022-03-26-TrueNAS-Reenable-apt-get.md)

TrueNAS core, does not offer very wide hardware compatibility. (Scale- supports anything that will work on linux)

Not- really a CON- but, for best experiences, use Intel / Chelsio / Mellonax NICs. 

!!! info
    I recommend Intel / Mellonax / Chelsio NICs for EVERYTHING.

    They are plug and play with Linux, BSD, and Windows.

    Many cases of bad performance on a NAS, boils down to bad NICs. Realtek is not recommended. 

    In general, Intel/Mellonax/Chelsio has hardware offload for many various networking functions, which will reduce the load on your main processor.

ECC ram is strongly recommended.

!!! info
    Again- not really a CON exactly- but, ECC is strongly recommended for TrueNAS.

    It protects your data while it is in-memory waiting to be written to disk.

Enjoys lots of memory. Especially if you use dedup. 

!!! info
    Again- not really a con- BUT, TrueNAS / ZFS typically needs more ram then other options.

    If you enable deduplication- for best results, you [will want 1-3G of ram per 1TB of data.](https://www.truenas.com/docs/references/zfsdeduplication/#:~:text=Pools%20suitable%20for%20deduplication%2C%20with,per%201%20TB%20of%20data.){target=_blank}

##### Adding Storage
Adding more storage - Expansion has always been a pain-point with ZFS in general. You have a few options for expanding storage-

1. Replace each drive in your pool, one by one, with bigger drives. 
    - This takes a long time, and increases the risk to your array while its in progress.
2. Add another redundant vDev
    - While- you can add a non-redundant vdev- I always recommend redundancy. 
    - This- just requires you to add 2 or more disks, as a new stripe to your pool.
3. ZFS Expansion
    - This has been kicked around for years at this point.
    - [Was finally added to OpenZFS in 2023](https://github.com/openzfs/zfs/pull/12225){target=_blank}
    - Should end up in TrueNAS soon, mabye?


##### Permissions

The ACLs and Permissions for TrueNAS, are- extremely powerful. They, can also be extremely intimidating for new users to CORRECTLY setup and configure.

This- is both a pro, and a con.

#### When would I recommend using this?

If you want fast and reliable file and block shares- TrueNAS Core is hard to beat.  You can install it on your own hardware, and let it fly.

If- you want to run apps, I would recommend instead going with TrueNAS Scale. You may lose a slight bit of performance (For 1/10G networks, you likely won't notice anything), but, you gain a ton of flexibility and ease of use. 

Scale, is also quite useful for running VMs. (I don't recommend running VMs in Core- bhyve is fast- but, historically has had issues virtualization some platforms, and in general, is pretty far behind QEMU/KVM in terms of functionality.)

### Unraid

#### Brief Intro

Unraid, is a storage-centric OS, which is designed to be installed, and boot from a USB thumb drive. 

In its current state, it offers SMB and NFS file sharing, apps via Docker, VMs via QEMU/KVM, and offers a few options for storage (ZFS, BTRFS, XFS)

#### My History

I first started using Unraid, in 2020, when I was looking to build a new NAS.

Originally, I looked at Synology/QNAP/Drobo units, and was disappointed with the high price tags.

So- I decided to build my own NAS, for less then the cost of a off-the-shelf NAS. Enter- the [500$ Closet NAS](https://xtremeownage.com/2020/07/24/closet-mini-server-build/){target=_blank} (While- it originally ran proxmox- it was replaced with Unraid after a few months) [I did write a blog post for this](https://xtremeownage.com/2020/10/20/unraid-vs-proxmox-my-opinions/){target=_blank}

The simplicity and ease of use of this platform, is what kept me interested. The GUI, is clean, and easy to navigate... And, its quite capable of both containers, and VMs.

You can run your apps, via docker containers, or docker compose very easily.

I also, [Turned my gaming PC into an unraid VM](https://xtremeownage.com/2021/03/20/how-to-convert-your-physical-gaming-pc-into-an-unraid-vm-w-passthrough/){target=_blank} quite successfully with Unraid. 

In 2021, after TrueNAS Scale reached beta, [I replaced Unraid with TrueNAS Scale](./../2021/unraid-vs-truenas-scale.md){target=_blank}. The reasons were mostly due to the single-spool performance limitations of its main array causing bottlenecks.

And- in 2023, after Unraid announced OFFICIAL ZFS-Support, I ended up retiring TrueNAS and moving back to Unraid, where it is still running, and serves up 90% of my NFS/SMB shares. I did convert it from bare metal, to a VM running on my Proxmox cluster too.

##### Storage Concepts

###### Array

For storage, there are two concepts- Arrays, and Pools. Arrays, refers to the "Unraid Array", which... is the unraid-secret-sauce.

It, uses disks, not in an actual raid array. So- when reading or writing, you only access the disk containing that one specific file. This- is really useful for when you are trying to build an extremely energy efficient NAS, as the rest of the drives can continue to sleep.

To assist with performance issues- it does support using cache pools, so you can write the new data to flash, and it will get moved to the array later on.

Parity, is calculated when a file is written, and stored to the optional parity disks. There is also a scheduled parity check, that I personally run every month.

To expand, you just add more disks, and wait for it to rebuild the parity. Its that simple.

###### Pool

Storage pools, allows you to configure additional "Pools". Around 2023, native ZFS support was added to pools. So- you can now run various ZFS configurations, directly managed by Unraid. You can also configure files to be automatically moved from a pool, to an array. 

An upcoming update, allows you to configure moving files between different pools. (Write to a cache pool, and later move to a storage pool, for example). In addition to ZFS, BTRFS is also supported, and you can also use non-redundant options such as XFS.

#### Pros

Extremely flexible for storage arrangements. ZFS, BTRFS, "Unraid's Array". You can easily extend unraid arrays. You can add/remove ZFS pools.

Power efficiency- Unraid has one advantage over every other option on this list. Due to how its "array" works, you only need to spin up the disk containing the file you are accessing. All of the other drives, can continue to sleep. This is a massive boost to power efficiency, especially if you have a large number of disks.

You can add/remove parity at any time, before, or after the pool is created.

The built in docker interface, is one of my favorite interfaces for containers. Its simple, but, powerful.

The built in virtualization interface, is also nice. You can easily pass through hardware to VMs.

The interface in general- is extremely pleasant to use, and is by-far my favorite interface from all of the solutions I have personally used. 

Permissions- They don't get easier. You set permissions at the share level. Everything inside of the share- is basically `chown nobody:users && chmod ug+rwx,o-rwx` As such, permissions work very easily across NFS, and CIFS. You set them at the top-level, and you forget about them.

In addition to the beautiful app catalog (which is basically docker containers, with a installation interface around them), you can also single-click packages to extend system functionality. For example- I have sanoid to manage my ZFS automatic snapshots and retention. I have a plugin for Nvidia GPU drivers, I have a plugin which expands the dashboard to add GPU stats. The UI can be expanded with additional functionality, quite easily. 

This- is both a pro, and a con- but, it does offer the ability to configure a caching tier. The cache works extremely well, when you are writing. But- is not as effective for a read cache. It is not very intellegent. You can install a plugin to tune the mover settings, to better customize how the cache is leveraged. You can also create multiple cache pools for your array- For example- both a read cache, and a write cache. Cache/Storage/Array settings are configured on a share-by-share basis, and not globally. So- you can cache your photos share, don't cache your ISOs share, and keep your appdata share only on flash.

#### Cons

The Unraid "Array" is limited to the performance of a single spool. In previous years, before the ability to add multiple pools exist, this was a problem for me.

Performance in general- Unraid isn't the fastest NAS, not even close. If you have a share that exists on your array, it will use FUSE/SHFS to combine the mounts togather- FUSE does not perform very well.. At all.

Unraid 6.12, did add exclusive shares- which, if you have a share that only exists on a single pool(not array!), it bypasses FUSE/SHFS, which drastically improves performance. This- is extremely useful with ZFS pools.

NFS - I have a personal gripe regarding its NFS management. The interface for adding NFS ACLs honestly, sucks. The interface in its current state (as of June 2024), is not really suitable at all for adding NFS ACLs. Its a single-line text box. 

Permissions - While- the simple permissions are a huge pro- they are also a huge con. They are not granular, and are typically only set at the top level.


#### When would I recommend Unraid?

Honestly- Unraid is PERFECT for a media server. 

The array, is extremely suitable, as you don't need high levels of redundancy for media, and it does offer parity. The use-case of a media server is one of my primary reasons I use Unraid. 

Unraid, is also good, if you have hardware with extremely limited resources, and you don't have room for a dedicated boot disk, since it boots and runs from a USB thumb drive. 

It also, offers extremely easy expansion of storage, by just adding a drive. 

If you want to maximize energy efficiency, installing Unraid on low-power hardware, is a very easy way to do it. Its array, is the most power-efficient option listed here, as you can access a file without spinning up all of your disks.

### Synology

Synology - A small, efficient self-contained Software+Hardware solution.

I feel- these units are pretty well-known, so, I don't think there is much to say here.

#### My history

If you have been reading along- I have spent YEARS avoiding these units, just due to the price. 

Anyways- a few months back, I was having issues with backups, due to the NFS connection on my unraid box, being very... finnicky, at times. After doing a bunch of research on various units, I decided to pick up a DS423+, for the primary use-case, as a one-stop shop for all of my backups, and cloud replication. 

The only downside of this unit, compared to more expensive ones is...

1. The lack of any expansion.
    - Not an issue- as I primarily intend on using it for backups. 4x8T HDDs is MORE then plenty for the use-case.
2. The lack of 10GBe. (Only includes 2x 1GBe)
    - After debating if it was worth spending 400$ more, I decided it wasn't.
    - That being said, my backups do run slower- however, they are based on snapshots, and run in the middle of the morning. And- they actually have been able to leverage both NICs when running to get up to 2Gbits of bandwidth, in ideal scenarios, during multiple backup operations.

That being said- if you want to see how I have used the synology for my backup strategies- Please see... [My Backup Strategies](./2024-06-11-Backup-Strategies.md).

(It was originally all here- but, after a certain point- it got long enough that I felt it deserved a dedicated post...)

That being said, it has a lot of very useful tools built in for taking backups, automating snapshots and retention, and cloud replication. I am extremely satisfied with it for this purpose.


## Distributed Storage Solutions

### Ceph

[Ceph](https://docs.ceph.com/en/reef/){target=_blank} is a storage solution which offers object, and and block location.

It is typically used in an extremely distributed fashion, with data being spread across multiple OSDs (OSD = basically a physical disk). When correctly implemented, it is bar-none the most redundant and reliable system here.

While- it is NOT technically a NAS, I believe it does fit here.

I built my [ceph cluster in 2023](./../2023/2023-08-08-proxmox-ceph.md){target=_blank}, and it hosts 98% of my VM storage, LXC storage, and Kubernetes storage via the [Ceph-CSI](https://github.com/ceph/ceph-csi){target=_blank}.

Before I converted all of my hardware into a giant proxmox cluster, and I ran bare metal kubernetes on my nodes, I did use [rook-ceph](https://rook.io/){target=_blank}, which uses the above ceph-csi, and automatically handles creating and maintaing a ceph cluster across your kubernetes environment. 


The reason I use ceph- it allows my VMs to easily attach to their storage, regardless of where they are, or what host they are on. The same applies to my kubernetes storage. [Ceph RBD](https://docs.ceph.com/en/latest/rbd/){target=_blank} typically uses iSCSI for remotely attaching- however, it can [also leverage NVMe-oF](https://docs.ceph.com/en/latest/rbd/nvmeof-overview/){target=_blank}.

!!! info    
    Ceph is NOT a general purpose NAS, or file sharing distribution, and is not suitable to become one.

    It is included on this list- due to its ability to easily provide block, file, and object level storage.

#### Kubernetes Specific-

##### Ceph-CSI

Only needs to run a single daemonset, with a pod-per node where you will consume ceph storage, and a single pod for the rbd provisioner. 

In my current 5-node cluster, it only uses 6 pods, with a total of 0.01 average CPU usage, and 572MB of ram.

The Ceph-CSI is used directly when you want to connect to an existing Ceph-Cluster. If you want to create/host a ceph-cluster, use [rook-ceph](https://rook.io/){target=_blank}. It will have a higher pod overhead, due to actually creating, hosting, and maintaining the cluster.

Use this, to create PVCs hosted on an external ceph-cluster.

##### Rook-Ceph

[Rook-ceph](https://rook.io/){target=_blank}, includes the [Ceph-CSI](https://github.com/ceph/ceph-csi){target=_blank}, and also handles the deployment, configuration, and maintenance of a ceph-cluster inside of your kubernetes cluster.

Use this- if you want to deploy a ceph cluster inside of your kubernetes cluster.

##### Openshift / OKD.IO Specific

If you use Openshift, [Red Hat OpenShift Data Foundation](https://www.redhat.com/en/technologies/cloud-computing/openshift-data-foundation), is an out of the box-capable cluster operator, which will deploy, and manage rook-ceph, ceph-csi, and a few other charts to deploy, manage, and configure ceph-storage within Openshift. [Openshift DataFoundation Architecture](https://access.redhat.com/documentation/en-us/red_hat_openshift_data_foundation/4.9/html/red_hat_openshift_data_foundation_architecture/openshift_data_foundation_operators){target=_blank}

While- I don't have hands on experience with this particular flavor of ceph-management, If you are using Openshift, this means you have RHEL support. And- Openshift Data Foundation, also has RHEL support, making this a good fit, unless you have an external ceph cluster, in which case, you should likely stick to the [Ceph-CSI](https://github.com/ceph/ceph-csi){target=_blank}. 

Use this, when you are running Openshift, and you want to host a ceph-cluster inside of your kubernetes environment.

#### Pros

It runs on standard hardware, and uses traditional IP networking

While, the default keeps three replicas of each bucket of data, for redundancy purposes, you can configure ceph with "parity". See [Ceph - Erasure Coding](https://docs.ceph.com/en/latest/rados/operations/erasure-code/){target=_blank}


##### Scalability

This is bar-none, the most scalable solution on this list. You can scale from gigabytes, to hundreds of petabytes. Performance also scales quite well.

Ceph can scale from a single host, to thousands of hosts on a global scale.

You can effortlessly add more OSDs (Disks), and/or hosts, and ceph will automatically replicate and spread the data out. No need to wait for parity calculations, the new storage is INSTANTLY available. 

##### Redundancy 

This, also, bar-none, is the most redundant solution on this list. 

You can configure ceph with OSD level redundant (protects against loss of individual drives), you can set node level redundancy (protects against loss of entire servers), you can set rack or chassis level redundant (protects against failures of an entire rack), and you can even set data-center, or REGION level redundancy. Of course- you need enough hardware, with the proper separation for this.

How many different storage solutions can you run at your HOUSE, which can tolerate multiple-node failures without storage interruption? 

!!! info
    Keyword is "House/Home". Most people even in r/homelab, don't run a full-blown SAN just due to energy and noise concerns.

    A mostly empty disk shelf, controller, and fibre channel switch can easily consume >= 500 watts, and... noise is not a design factor in an enterprise SAN.

    But- they do have the ability to offer very good redundancy. Not- on the same level of ceph- but, you can easily build a highly redundant SAN. 

You can set different redundancy configurations, for different pools, via [Crush Maps (documentation)](https://docs.ceph.com/en/latest/rados/operations/crush-map/){target=_blank}

##### Flexibility

While- Ceph is not a NAS, or a file sharing solution, it offers a ton of flexibility. It can provide block storage via RADOS/RBD, It can provide File (NFS) storage via Ceph FS, it can provide S3/Object storage.

You can perform snapshots on objects in ceph, you can clone snapshots, mount copy on write snapshots. Its, extremely flexible, within its capabilities.

#### Cons

You MUST use enterprise SSDs. Consumer SSDs will cause chaos on your cluster. Don't build a cluster from Samsung 970 evos. I did this, and the performance was so horrible, it would crash workloads.

Can be hardware intensive- recommended minimum of three nodes for redundancy purposes. Don't- recommend running on extremely low powered hardware, stick to intel core / ryzen / xeon / etc, or better. Its not suitable for running on a raspberry pi.

Ceph will destroy crappy NICs. As an experiment once, I added an OSD to one of my optiplex 3060 micros (the 3xxx series typically has realtek NICs). The networking stack on this box has never have given me issues, and has been running VMs / LXCs for years, without fault. Ceph- would straight up destroy its networking stack, facilitating the need to completely reboot the host, and then killing it again after a while. Make sure you have a good Intel / Chelsio / Mellonax NIC. Don't use realtek here!

No built in backup/restore functionality. Needs another service to handle backups and restores.

##### Performance

Ceph is extremely latency sensitive. You NEED as little latency as possible on a ceph network. Latency will really hurt performance. Recommended fast, layer 2 switching only.

Fast networking is a REQUIREMENT. 10GBe is a bare minimum for any sizable cluster, outside of a POC environment. 25/40/100GBe is preferred. 

At small scale, you will only get a fraction of the performance out of ceph, as you put into it. 

##### Configuration

Configuration, can be tedious. Most configuration changes are done via [Crush Maps (documentation)](https://docs.ceph.com/en/latest/rados/operations/crush-map/){target=_blank}

If, you are using [rook-ceph](https://rook.io/){target=_blank}, or [Ceph via Proxmox](https://pve.proxmox.com/wiki/Deploy_Hyper-Converged_Ceph_Cluster){target=_blank}, these options have all of the basic configurations easily exposed in an easy to use way.

[Proxmox's ceph integration](https://pve.proxmox.com/wiki/Deploy_Hyper-Converged_Ceph_Cluster){target=_blank} is essentially effortless to create, configure, and manage a ceph cluster. You can single-click add OSDs, configure your monitor / manager hosts, and it has a built-in dashboard for status, metrics, etc.

But, in general, for more settings, you will need to modify crush maps. 

#### When would I recommend ceph?

I would recommend ceph, anytime you have at least three nodes with enough spare resources to run ceph, when you have 10G or faster networking, and, you are either using kubernetes, or proxmox (or another virtualization distribution which provides native ceph support). I recommend it for kubernetes PVCs/PVs, and Proxmox VMs.

For Kubernetes SPECIFICALLY- there are a few alternatives to ceph, which can offer better performance, and/or, other features. Those are longhorn.io, and portworx.

Each- has pros and cons, which will be addressed below.

### Longhorn.IO (Kubernetes SPECIFIC Storage)

[Longhorn.IO](https://longhorn.io/docs){target=_blank} is a open-source distributed storage solution for Kubernetes, provided by Rancher/SUSE.

It works similar to ceph, in that replicas are scattered amongst difference nodes to provide redundancy. However- it also differs in many ways as well.

#### Pros

Basically single click plug and play with rancher. Extremely easy to setup and configure regardless with its helm chart.

Great documentation. 

Adding more disks, is very easy.

Where ceph typically consumes an entire disk- longhorn can leverage a path/mount on a shared disk.

Built in automatic backups and snapshots functionality- This is an EXTREMELY nice feature, which has saved my bacon a few times before. You can slap longhorn into a brand-new kubernetes environment, and point it at your existing backups path (NFS, or S3), and effortlessly migrate / restore storage.

The GUI, is nice. Its simple, but, offers all of the needed information. Everything can be configured via the GUI, OR via the CLI. It has a dashboard, that covers the basic details needed. You can create snapshots, clones, delete/create/etc via the GUI.

Compared with ceph, you can get superior performance, at smaller scales. Since you can tune data locality- it will move a pod's storage to be local to the node if possible offering improved performance, and less latency. At massive-scale though, ceph will still be superior. (Not- r/homelab scale.)

##### Version 2 Engine 
In addition to being able to tune data locality, the [version 2 data engine](https://longhorn.io/docs/1.6.2/v2-data-engine/quick-start/){target=_blank} which is still in development, appears it will be able to offer vastly improved performance.

1. It uses NVMe-of
2. Each volume will consume, a single dedicated CPU core, which processes I/O request. This- can be a CON, but, can be a pro in terms of the performance it "should" offer.

Longhorn has [produced performance comparisons between v1, and v2 engines](https://longhorn.io/docs/1.6.2/v2-data-engine/performance/){target=_blank}. The gist- it will offer DRASTICALLY improved performance, even capable of exceeding the performance of a local path / disk. In most cases, it appears the IOPs will be between 75-150% of what is obtainable from a local mount/disk, while read bandwidth scales with the number of replicas offering potentially drastically better performance. Latency, with distributed replicas will never be able to compete with a local path- however, for a single-replica test with v2 engine- it offers near bare-metal latency.

That being said, I am really excited to see where this goes.

#### Cons

##### Replica replication issues / out of sync replicas

I last used ceph a few years ago, but, I do keep tabs on the development. It is very likely these issues have already been addressed.

But- I did previous have issues with replicas unable to replica occasionally, or establish a quorum. This, would be quite noticeable when experiencing loss/failure of a node, requiring manual, administrative action to correct.

With ceph- this is not an issue, as it writes to all replicas at the same time, rather then just replicating the local copy. 

With this issue-I have had issues where a pod would move around, and suddenly, be on a three-week old copy of the data, forcing me to restore from backup. Although- restoring from backup is extremely easy with longhorn's GUI.

##### Pod Count

Longhorn will create a lot of pods. This can be a major factor if you are limited or charged by pod count.

Where as my ceph-csi uses a grand-total of 6 pods, a fresh install of longhorn into my cluster, with a single volume (not attached), uses 27 pods. You can reduce this- as the default deploys 3 pods for each service for redundancy- but- here are the deployments and sets.

Deployments:

1. csi-attacher
2. csi-provisioner
3. csi-resizer
4. csi-snapshotter
5. longhorn-driver-deployer
6. longhorn-ui

DaemonSets:

1. engine-image
2. longhorn-csi-plugin
3. longhorn-manager

#### When would I recommend longhorn?

If you only need storage for kubernetes, you want something that is easy to setup and configure, easy to manage, easy to monitor, longhorn is a good fit.

It is not picky with SSDs like ceph. It doesn't mind shared storage either. So, you can host longhorn storage on your primary partition if you wish.

It, is by far, the easiest option, and the built-in snapshots and backups, is a MASSIVE win. (With ceph- I need to rely on Veeam/Kasten K10 for backups). Although- ceph can do snapshots, and does do replication.

Within the rancher ecosystem, its also natively integrated into the rancher user interface, making it effortless to use.

### Pure Storage - Portworx (Kubernetes SPECIFIC Storage)

This- is one I don't yet have experience with, however, I am preparing an enterprise deployment.

That being said- I will list the pros, and cons which have caught my attention that I look forward.

!!! note
    As stated! I have personal experience with EVERY OTHER solution listed on this page.

    I am still in the process of researching to deploy Portworx at an enterprise scale. 

That being said- portworx appears to work simlier to both ceph, and longhorn, in the sense data is replicated amongst the cluster, and can be remotely attached.

It does have data locality features to allow the primary data replica to be mounted local to your pod.
#### Pros

Performance. Based on many benchmarks I have seen, at this time(Mid-2024), portworx is one of the best performing options. Although, longhorn's v2 data engine has promise.

Built in DR. While Ceph has cross-region replication capablities, and longhorn has automatic backups/snapshots- I'd argue portworx is a step ahead- with automatic DR replication. [Docs](https://docs.portworx.com/portworx-enterprise/operations/operate-kubernetes/disaster-recovery){target=_blank}

Integration with Pure Storage Flashblades, and Flash Arrays. Not- a useful feature for `r/homelab`, however, this is incredibly useful for enterprise deployments.. Pure storage builds one of the best SAN solutions around, IMO.

Built in backups / replication / cross-cluster migrations. 

#### Cons

It can be expensive. Typically not suitable for a homelab. Although, there is an [Essentials License](https://docs.portworx.com/portworx-enterprise/operations/licensing/portworx-licenses){target=_blank}, which does let you use most of the functionality for free, with... restrictive limitations. But- for an enterprise situation, where you already own the FlashArray/Flashblades- its pennies.

#### When would I recommend using this?

When you are an enterprise shop, who either already owns Pure Storage hardware, and support.


## Sources

Unraid Documentation - https://docs.unraid.net/category/unraid-os/

Synology Documentation - https://kb.synology.com/en-in

Ceph Documentation: https://docs.ceph.com/en/latest/start/intro/


### Kubernetes-Specific Documentation

Ceph-CSI Documentation: https://github.com/ceph/ceph-csi

Rook-Ceph documentation: https://rook.io/docs/rook/latest-release/Getting-Started/intro/

RHEL Openshift Data Foundation Documentation: https://access.redhat.com/documentation/en-us/red_hat_openshift_data_foundation/4.15

Longhorn Documentation: https://longhorn.io/docs/1.6.2/

Portworx Documentation: https://docs.portworx.com/portworx-enterprise