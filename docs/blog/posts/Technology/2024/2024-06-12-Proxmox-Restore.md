---
title: "Proxmox - Reinstall host without losing cluster configuration"
date: 2024-06-12
tags:
  - Homelab
  - Proxmox
---

# Proxmox - Howto: Restore PVE Host Configuration

So, literally ONE DAY after writing [My backup strategies post](./2024-06-11-Backup-Strategies.md){target=_blank}, I encountered a need to completely reinstall proxmox.

As it turns out, there is not a documented, nor official restore process. After some trial and error, I did manage to completely restore my host, with no loss in configuration.

<!-- more -->

## What happened?

So- here I was minding my own business, and all of a sudden- my entire network goes Kaboom. 

Kubernetes is down, DNS is down, Home Assistant is down... and, very little was working correctly.

After running my trusty [PingInfoView](https://www.nirsoft.net/utils/multiple_ping_tool.html){target=_blank}, which I have configured with the IP addresses of my infrastructure- I noticed my r730XD was completely offline.

After accessing it with iDrac, and opening the remote console- I discovered... It was unable to boot. Its boot NVMe was officially shot.

After opening one of my other proxmox nodes by IP, I also discovered, well. basically everything was offline, as my ceph cluster had become unavailable.

The reasoning for this- Apparently I did not have enough MONs to create a quorum, and when the host went down, ceph went down with it.

That- was its own fun to correct- but, that isn't the purpose of this post. This post, is about reinstalling a proxmox server, and just having it come back online magically, without losing any configuration.

!!! info
    This article ASSUMEs you have a cluster with at least one other healthy machine.

    If not, this post is not for you.

Per my [post on backups](./2024-06-11-Backup-Strategies.md){target=_blank}, I do not do full image level backups for these hosts, as you can reinstall them, and just reconfigure them.

But, I do, do configuration backups of /etc/pve, as this drive holds the cluster state.

## How to restore the host

### First- Reinstall Proxmox.

1. Reinstall proxmox on the host.

Make sure to set the hostname and network the same as it was before.

2. Update / Prepare the new OS

At this point, I also ran the [tteck Post Install Script](https://tteck.github.io/Proxmox/#proxmox-ve-post-install){target=_blank} to update the repos, disable enterprise repos, disable nag, etc.

And- I did a full `apt-get update && apt-get dist-upgrade` to get everything installed, and updated.

Next- I logged into this machines GUI, directly by IP, and clicked on ceph, and told it to install the ceph packages for the version the rest of my cluster is using.

After the packages installed- I clocked out without completing the configuration.

Next, I ran my ansible-playbook to update the SSH keys, kernel power savings mode, apply IPMI scripts, install common packages and tools I use, and do basic machine configuration. These- steps don't impact proxmox.

At this point- you should have a fully functional stand-alone host. Now- we start the "fun" part.

### Restoring the configuration

!!! danger
    These steps ARE completely unsupported, and may break your entire cluster!!!

    I came up with these steps through my own process of trial and error.

    This may not work for you. This may break your cluster and cause data loss.

    Enter at your OWN risk. 
    
    I do not take any responsibility for any losses or damages which may occur from you following my unofficial 3rd party documentation.

With- the warning out of the way- I will say- I was able to completely recover my cluster.

This entire guide assumes you are running as root.

#### Step 1. Prepare remote access to a working machine.

The first thing we need to do, is establish PKI between the new server, and one of the existing nodes.

Get the public key for your new server. `cat ~/.ssh/id_rsa.pub`

If, for some reason, the above file does not exist, then create one. `ssh-keygen`, and then copy the public key from the above command.

Visit one of your working servers, as root, `nano ~/.ssh/authorized_keys`, and paste the public key in on a new line.

Go back to the new machine, we need to add the old machine to our hosts file, just to make this slightly faster/easier. Although, if you wish, you can do all of the rsync commands using the IP as well.

But- `nano /etc/hosts`, and add a line. `10.1.2.3    kube01` Save, and you are done.

After those two steps- this command should automatically establish a ssh session with the other server.

`ssh root@oldmachine`

``` bash
root@kube02:/var/lib/ceph# ssh root@kube01
Linux kube01 #1 SMP PREEMPT_DYNAMIC PMX 6.8.4-2 (2024-04-10T17:36Z) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Wed Jun 12 18:35:22 2024 from
root@kube01:~#
```


#### Step 2. COMPLETELY stop Proxmox

Goto the new host, the one which we are installing. We need to stop ALL proxmox related services.

``` bash
systemctl stop pve-cluster
systemctl stop pvedaemon
systemctl stop pveproxy
systemctl stop pvestatd
systemctl stop corosync
systemctl stop pve-ha-lrm
systemctl stop pve-ha-crm
systemctl stop pve-firewall
systemctl stop pvescheduler
```

#### Step 3. Prepare /etc/pve

The `/etc/pve` directly will automatically be synced from your other cluster nodes once corosync and pve-cluster are running.

We are going to move it elsewhere, and prepare the directory.

``` bash

# Move the pve directory somewhere else.
mv /etc/pve ~/pve_backup

# Create a new PVE directory
mkdir /etc/pve

chown root:root /etc/pve

```

#### Step 4. Corosync

To get corosync running, we are just going to copy and paste from another host.

``` bash
# Update this to match the name of the source server, which is a cluster member that is currently running.
SOURCE=your-old-server

# Copy over corosync configuration
scp root@$SOURCE:/etc/corosync/corosync.conf /etc/corosync/corosync.conf
scp root@$SOURCE:/etc/corosync/authkey /etc/corosync/authkey

# Set permissions and ownership.
chown root:root /etc/corosync/corosync.conf
chown root:root /etc/corosync/authkey
chmod 600 /etc/corosync/authkey

# Start corosync.
systemctl start corosync

# Watch journalctl output, to ensure its working. Once it looks happy, CTRL+C
journalctl -fe
```

This, is all of the configuration we need for corosync to work. If, corosync fails, you will need to identify and correct the issue. `journalctl -fe` is a good place to start.

#### Step 5. PVE-Cluster

At this point, you should have the corosync service running. We need to start on pve-cluster.

Start the service.

``` bash 
systemctl start pve-cluster
```

But, you will notice- it throws an error when querying the status.

``` bash
root@kube02:/etc# pvecm status
Error: Corosync config '/etc/pve/corosync.conf' does not exist - is this node part of a cluster?
```

To fix this, we just need to copy the corosync file. Note- this step has to be done here. 

``` bash
cp /etc/corosync/corosync.conf /etc/pve/
```

Here is my output from this process.
``` bash
root@kube02:/etc# pvecm status
Error: Corosync config '/etc/pve/corosync.conf' does not exist - is this node part of a cluster?
root@kube02:/etc# cp /etc/corosync/corosync.conf /etc/pve/
root@kube02:/etc# pvecm status
Cluster information
-------------------
Name:             Cluster0
Config Version:   11
Transport:        knet
Secure auth:      on

Quorum information
------------------
Date:             Wed Jun 12 18:12:08 2024
Quorum provider:  corosync_votequorum
Nodes:            5
Node ID:          0x00000004
Ring ID:          1.9e1
Quorate:          Yes

Votequorum information
----------------------
Expected votes:   5
Highest expected: 5
Total votes:      5
Quorum:           3
Flags:            Quorate

Membership information
----------------------
    Nodeid      Votes Name
0x00000001          1 10.100.4.106
0x00000002          1 10.100.4.100
0x00000003          1 10.100.4.105
0x00000004          1 10.100.4.102 (local)
0x00000005          1 10.100.4.104
```

!!! info
    The corosync.conf needs to be copied to `/etc/pve` AFTER we start the pve-cluster service.

  If you did this before starting pve-cluster, you would receive errors regarding the /etc/pve directly not being empty (as it mounts a cluster file system there.)

  If- you did make that mistake- just start over at step 2.


#### Step 6. Reboot

Reboot the host, and wait for it to come online.

After the host comes online- It should be acting like a cluster member now, and should be visible in your cluster's standard interface.

But- there a few more steps you may need to perform....


#### Step 7. Reimport ZFS Pools

If, you have ZFS pools, you may need to re-import them.

You also may notice errors in your `journalctl -fe` output.

``` bash
Jun 12 18:27:29 kube02 pvestatd[3033]: storage 'NOYB' is not online
Jun 12 18:27:29 kube02 pvestatd[3033]: zfs error: cannot open 'GameStorage': no such pool
Jun 12 18:27:30 kube02 pvestatd[3033]: zfs error: cannot open 'GameStorage': no such pool
Jun 12 18:27:30 kube02 pvestatd[3033]: could not activate storage 'GameStorage', zfs error: The pool can be imported, use 'zpool import -f' to import the pool.
Jun 12 18:27:30 kube02 pvestatd[3033]: storage 'ISOs' is not online
Jun 12 18:27:42 kube02 pvestatd[3033]: storage 'NOYB' is not online
Jun 12 18:27:42 kube02 pvestatd[3033]: zfs error: cannot open 'GameStorage': no such pool
Jun 12 18:27:42 kube02 pvestatd[3033]: zfs error: cannot open 'GameStorage': no such pool
Jun 12 18:27:42 kube02 pvestatd[3033]: could not activate storage 'GameStorage', zfs error: The pool can be imported, use 'zpool import -f' to import the pool.
```

The fix is simple enough, and is even provided in the log output: `zpool import YourPoolName -f`

``` bash
root@kube02:/var/lib/ceph# zpool import GameStorage
cannot import 'GameStorage': pool was previously in use from another system.
Last accessed by kube02 (hostid=7060dad4) at Sun Jun  9 00:24:41 2024
The pool can be imported, use 'zpool import -f' to import the pool.
root@kube02:/var/lib/ceph# zpool import GameStorage -f
root@kube02:/var/lib/ceph# zpool status
  pool: GameStorage
 state: ONLINE
  scan: scrub repaired 0B in 00:00:40 with 0 errors on Sun Jun  9 00:24:41 2024
config:

        NAME                                            STATE     READ WRITE CKSUM
        GameStorage                                     ONLINE       0     0     0
          nvme-Samsung_SSD_970_EVO_1TB_S5H9NS0NA99060M  ONLINE       0     0     0
```

At this point, you might also want to kick off a scrub. (My storage was very rudely shutdown when the boot drive died...)

To do so, just type `zpool scrub YourPoolName`

It will continue running in the background with no additional attention needed.

``` bash
root@kube02:/var/lib/ceph# zpool status
  pool: GameStorage
 state: ONLINE
  scan: scrub in progress since Wed Jun 12 21:02:55 2024
        41.7G / 41.7G scanned, 6.44G / 41.7G issued at 549M/s
        0B repaired, 15.44% done, 00:01:05 to go
config:

        NAME                                            STATE     READ WRITE CKSUM
        GameStorage                                     ONLINE       0     0     0
          nvme-Samsung_SSD_970_EVO_1TB_S5H9NS0NA99060M  ONLINE       0     0     0

#And, eventually, it will finish
root@kube02:/var/lib/ceph# zpool status
  pool: GameStorage
 state: ONLINE
  scan: scrub repaired 0B in 00:01:37 with 0 errors on Wed Jun 12 21:04:32 2024
config:

        NAME                                            STATE     READ WRITE CKSUM
        GameStorage                                     ONLINE       0     0     0
          nvme-Samsung_SSD_970_EVO_1TB_S5H9NS0NA99060M  ONLINE       0     0     0
```

#### Step 8. Reimport Ceph OSDs

!!! info
  This step assumes, you have a "somewhat" healthy ceph cluster at this point, and are just needing to reimport your existing OSDs.

  If, you don't have functional monitors, and managers, you need to correct that first.

Since, I am running ceph, my OSDs are currently not running. We need to correct this.

!!! info
  This step can be used anytime you move a ceph OSD from one host to another, without rebuilding the OSD.

So- the first step- just make sure your ceph volumes are still there. They shouldn't be mounted at this point, as we are on a pretty fresh install still.


##### Gathering information

You, don't really NEED any information from this step- It just details on how to find and view the information.

If, you are sure your OSDs are on the host, and just aren't running, skip to the next step.

``` bash
root@kube02:/var/lib/ceph# lsblk
NAME                                                                                                  MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                                                                                                     8:0    0  14.6T  0 disk
└─sda1                                                                                                  8:1    0  14.6T  0 part
sdb                                                                                                     8:16   0   7.3T  0 disk
└─sdb1                                                                                                  8:17   0   7.3T  0 part
sdc                                                                                                     8:32   0   7.3T  0 disk
└─sdc1                                                                                                  8:33   0   7.3T  0 part
sdd                                                                                                     8:48   0  14.6T  0 disk
└─sdd1                                                                                                  8:49   0  14.6T  0 part
sde                                                                                                     8:64   0   7.3T  0 disk
└─sde1                                                                                                  8:65   0   7.3T  0 part
sdf                                                                                                     8:80   0   7.3T  0 disk
└─sdf1                                                                                                  8:81   0   7.3T  0 part
sdg                                                                                                     8:96   0  14.6T  0 disk
└─sdg1                                                                                                  8:97   0  14.6T  0 part
sdh                                                                                                     8:112  0   7.3T  0 disk
└─sdh1                                                                                                  8:113  0   7.3T  0 part
sdi                                                                                                     8:128  0  14.6T  0 disk
└─sdi1                                                                                                  8:129  0  14.6T  0 part
sdj                                                                                                     8:144  1   7.5G  0 disk
└─sdj1                                                                                                  8:145  1   7.5G  0 part
sdk                                                                                                     8:160  1  29.9G  0 disk
└─sdk1                                                                                                  8:161  1  29.9G  0 part
nvme0n1                                                                                               259:0    0 894.3G  0 disk
├─nvme0n1p1                                                                                           259:1    0  1007K  0 part
├─nvme0n1p2                                                                                           259:2    0     1G  0 part /boot/efi
└─nvme0n1p3                                                                                           259:3    0 893.3G  0 part
  ├─pve-swap                                                                                          252:3    0     8G  0 lvm  [SWAP]
  ├─pve-root                                                                                          252:4    0    96G  0 lvm  /
  ├─pve-data_tmeta                                                                                    252:6    0   7.7G  0 lvm
  │ └─pve-data                                                                                        252:8    0 757.8G  0 lvm
  └─pve-data_tdata                                                                                    252:7    0 757.8G  0 lvm
    └─pve-data                                                                                        252:8    0 757.8G  0 lvm
nvme6n1                                                                                               259:4    0 894.3G  0 disk
└─ceph--126d8000--5cdd--4ced--ab77--38893cd88dc8-osd--block--6db92940--fc38--4b0b--9fb4--4c5ac6742921 252:5    0 894.3G  0 lvm
nvme5n1                                                                                               259:5    0 894.3G  0 disk
└─ceph--8e2310de--b5ed--46bd--a32e--5048af46cfe0-osd--block--e06ae6d2--d881--40a0--adcd--2c55020474d5 252:2    0 894.3G  0 lvm
nvme7n1                                                                                               259:6    0 894.3G  0 disk
└─ceph--3f428911--5213--461d--a5fd--029f673d7ad2-osd--block--e65f3c81--23de--4f81--af2b--be185f6fef42 252:1    0 894.3G  0 lvm
nvme8n1                                                                                               259:7    0 894.3G  0 disk
└─ceph--25d71cae--e648--4a95--ae1f--c45f8fa547d7-osd--block--ae41fc24--8408--4656--8310--58e00a2a146b 252:0    0 894.3G  0 lvm
nvme2n1                                                                                               259:8    0 931.5G  0 disk
├─nvme2n1p1                                                                                           259:9    0 931.5G  0 part
└─nvme2n1p9                                                                                           259:10   0     8M  0 part
nvme1n1                                                                                               259:11   0 931.5G  0 disk
└─nvme1n1p1                                                                                           259:12   0 931.5G  0 part
nvme4n1                                                                                               259:13   0 931.5G  0 disk
└─nvme4n1p1                                                                                           259:15   0 931.5G  0 part
nvme3n1                                                                                               259:14   0 931.5G  0 disk
└─nvme3n1p1  
```

And- as we can see- they are here, nvme6 through nvme8.

A few commands to gather and show information-

In the status, we can see multiple OSDs are down, in this part: `1 host (4 osds) down`

``` bash
root@kube02:/var/lib/ceph# ceph status
  cluster:
    id:     016d27bb-5e11-4c85-846a-98f1f0b7ec08
    health: HEALTH_WARN
            1 osds down
            1 host (4 osds) down
            Degraded data redundancy: 593570/1780710 objects degraded (33.333%), 78 pgs degraded, 129 pgs undersized

  services:
    mon: 2 daemons, quorum kube05,kube01 (age 16m)
    mgr: kube05(active, since 2h), standbys: kube01
    mds: 1/1 daemons up, 1 standby
    osd: 13 osds: 9 up (since 15m), 10 in (since 3m)

  data:
    volumes: 1/1 healthy
    pools:   5 pools, 129 pgs
    objects: 593.57k objects, 1.3 TiB
    usage:   2.5 TiB used, 8.8 TiB / 11 TiB avail
    pgs:     593570/1780710 objects degraded (33.333%)
             78 active+undersized+degraded
             51 active+undersized

  io:
    client:   3.5 MiB/s rd, 1.6 MiB/s wr, 540 op/s rd, 192 op/s wr
```

Next- we check the lvms. You should see all of your missing OSDs here.

``` bash
root@kube02:/var/lib/ceph# ceph-volume lvm list


====== osd.3 =======

  [block]       /dev/ceph-3f428911-5213-461d-a5fd-029f673d7ad2/osd-block-e65f3c81-23de-4f81-af2b-be185f6fef42

      block device              /dev/ceph-3f428911-5213-461d-a5fd-029f673d7ad2/osd-block-e65f3c81-23de-4f81-af2b-be185f6fef42
      block uuid                qYPoy2-fQ4B-GeCy-yO4J-9KgO-tVfb-KT3Qeq
      cephx lockbox secret
      cluster fsid              016d27bb-5e11-4c85-846a-98f1f0b7ec08
      cluster name              ceph
      crush device class
      encrypted                 0
      osd fsid                  e65f3c81-23de-4f81-af2b-be185f6fef42
      osd id                    3
      osdspec affinity
      type                      block
      vdo                       0
      devices                   /dev/nvme7n1

====== osd.5 =======

  [block]       /dev/ceph-8e2310de-b5ed-46bd-a32e-5048af46cfe0/osd-block-e06ae6d2-d881-40a0-adcd-2c55020474d5

      block device              /dev/ceph-8e2310de-b5ed-46bd-a32e-5048af46cfe0/osd-block-e06ae6d2-d881-40a0-adcd-2c55020474d5
      block uuid                20e763-MU1H-9Yem-Qtru-R99T-tULs-V0QZhf
      cephx lockbox secret
      cluster fsid              016d27bb-5e11-4c85-846a-98f1f0b7ec08
      cluster name              ceph
      crush device class
      encrypted                 0
      osd fsid                  e06ae6d2-d881-40a0-adcd-2c55020474d5
      osd id                    5
      osdspec affinity
      type                      block
      vdo                       0
      devices                   /dev/nvme5n1

====== osd.6 =======

  [block]       /dev/ceph-126d8000-5cdd-4ced-ab77-38893cd88dc8/osd-block-6db92940-fc38-4b0b-9fb4-4c5ac6742921

      block device              /dev/ceph-126d8000-5cdd-4ced-ab77-38893cd88dc8/osd-block-6db92940-fc38-4b0b-9fb4-4c5ac6742921
      block uuid                qLe3KP-d5we-EENg-SlkG-KDuc-Ri3f-xivchq
      cephx lockbox secret
      cluster fsid              016d27bb-5e11-4c85-846a-98f1f0b7ec08
      cluster name              ceph
      crush device class
      encrypted                 0
      osd fsid                  6db92940-fc38-4b0b-9fb4-4c5ac6742921
      osd id                    6
      osdspec affinity
      type                      block
      vdo                       0
      devices                   /dev/nvme6n1

====== osd.7 =======

  [block]       /dev/ceph-25d71cae-e648-4a95-ae1f-c45f8fa547d7/osd-block-ae41fc24-8408-4656-8310-58e00a2a146b

      block device              /dev/ceph-25d71cae-e648-4a95-ae1f-c45f8fa547d7/osd-block-ae41fc24-8408-4656-8310-58e00a2a146b
      block uuid                bodGoC-XlhL-1TxK-x6K9-QqnF-h3LT-TRYkHy
      cephx lockbox secret
      cluster fsid              016d27bb-5e11-4c85-846a-98f1f0b7ec08
      cluster name              ceph
      crush device class
      encrypted                 0
      osd fsid                  ae41fc24-8408-4656-8310-58e00a2a146b
      osd id                    7
      osdspec affinity
      type                      block
      vdo                       0
      devices                   /dev/nvme8n1
```

##### Re-import the LVMs!

So- you might assume you need to manually rebuild systemd units, update configurations for proxmox, ceph, and do funky ceph commands.... But- that is not the case.

Just enter this command: `ceph-volume lvm activate --all`

Thats it!

Ceph will automatically re-mount the LVMs, create links, set ownership, create systemd unit files, and... basically handle nearly everything for you.

``` bash
root@kube02:/var/lib/ceph# ceph-volume lvm activate --all
--> Activating OSD ID 6 FSID 6db92940-fc38-4b0b-9fb4-4c5ac6742921
Running command: /usr/bin/mount -t tmpfs tmpfs /var/lib/ceph/osd/ceph-6
--> Executable selinuxenabled not in PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-6
Running command: /usr/bin/ceph-bluestore-tool --cluster=ceph prime-osd-dir --dev /dev/ceph-126d8000-5cdd-4ced-ab77-38893cd88dc8/osd-block-6db92940-fc38-4b0b-9fb4-4c5ac6742921 --path /var/lib/ceph/osd/ceph-6 --no-mon-config
Running command: /usr/bin/ln -snf /dev/ceph-126d8000-5cdd-4ced-ab77-38893cd88dc8/osd-block-6db92940-fc38-4b0b-9fb4-4c5ac6742921 /var/lib/ceph/osd/ceph-6/block
Running command: /usr/bin/chown -h ceph:ceph /var/lib/ceph/osd/ceph-6/block
Running command: /usr/bin/chown -R ceph:ceph /dev/dm-5
Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-6
Running command: /usr/bin/systemctl enable ceph-volume@lvm-6-6db92940-fc38-4b0b-9fb4-4c5ac6742921
 stderr: Created symlink /etc/systemd/system/multi-user.target.wants/ceph-volume@lvm-6-6db92940-fc38-4b0b-9fb4-4c5ac6742921.service → /lib/systemd/system/ceph-volume@.service.
Running command: /usr/bin/systemctl enable --runtime ceph-osd@6
 stderr: Created symlink /run/systemd/system/ceph-osd.target.wants/ceph-osd@6.service → /lib/systemd/system/ceph-osd@.service.
Running command: /usr/bin/systemctl start ceph-osd@6
--> ceph-volume lvm activate successful for osd ID: 6
--> Activating OSD ID 7 FSID ae41fc24-8408-4656-8310-58e00a2a146b
Running command: /usr/bin/mount -t tmpfs tmpfs /var/lib/ceph/osd/ceph-7
--> Executable selinuxenabled not in PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-7
Running command: /usr/bin/ceph-bluestore-tool --cluster=ceph prime-osd-dir --dev /dev/ceph-25d71cae-e648-4a95-ae1f-c45f8fa547d7/osd-block-ae41fc24-8408-4656-8310-58e00a2a146b --path /var/lib/ceph/osd/ceph-7 --no-mon-config
Running command: /usr/bin/ln -snf /dev/ceph-25d71cae-e648-4a95-ae1f-c45f8fa547d7/osd-block-ae41fc24-8408-4656-8310-58e00a2a146b /var/lib/ceph/osd/ceph-7/block
Running command: /usr/bin/chown -h ceph:ceph /var/lib/ceph/osd/ceph-7/block
Running command: /usr/bin/chown -R ceph:ceph /dev/dm-0
Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-7
Running command: /usr/bin/systemctl enable ceph-volume@lvm-7-ae41fc24-8408-4656-8310-58e00a2a146b
 stderr: Created symlink /etc/systemd/system/multi-user.target.wants/ceph-volume@lvm-7-ae41fc24-8408-4656-8310-58e00a2a146b.service → /lib/systemd/system/ceph-volume@.service.
Running command: /usr/bin/systemctl enable --runtime ceph-osd@7
 stderr: Created symlink /run/systemd/system/ceph-osd.target.wants/ceph-osd@7.service → /lib/systemd/system/ceph-osd@.service.
Running command: /usr/bin/systemctl start ceph-osd@7
--> ceph-volume lvm activate successful for osd ID: 7
--> Activating OSD ID 3 FSID e65f3c81-23de-4f81-af2b-be185f6fef42
Running command: /usr/bin/mount -t tmpfs tmpfs /var/lib/ceph/osd/ceph-3
--> Executable selinuxenabled not in PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-3
Running command: /usr/bin/ceph-bluestore-tool --cluster=ceph prime-osd-dir --dev /dev/ceph-3f428911-5213-461d-a5fd-029f673d7ad2/osd-block-e65f3c81-23de-4f81-af2b-be185f6fef42 --path /var/lib/ceph/osd/ceph-3 --no-mon-config
Running command: /usr/bin/ln -snf /dev/ceph-3f428911-5213-461d-a5fd-029f673d7ad2/osd-block-e65f3c81-23de-4f81-af2b-be185f6fef42 /var/lib/ceph/osd/ceph-3/block
Running command: /usr/bin/chown -h ceph:ceph /var/lib/ceph/osd/ceph-3/block
Running command: /usr/bin/chown -R ceph:ceph /dev/dm-1
Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-3
Running command: /usr/bin/systemctl enable ceph-volume@lvm-3-e65f3c81-23de-4f81-af2b-be185f6fef42
 stderr: Created symlink /etc/systemd/system/multi-user.target.wants/ceph-volume@lvm-3-e65f3c81-23de-4f81-af2b-be185f6fef42.service → /lib/systemd/system/ceph-volume@.service.
Running command: /usr/bin/systemctl enable --runtime ceph-osd@3
 stderr: Created symlink /run/systemd/system/ceph-osd.target.wants/ceph-osd@3.service → /lib/systemd/system/ceph-osd@.service.
Running command: /usr/bin/systemctl start ceph-osd@3
--> ceph-volume lvm activate successful for osd ID: 3
--> Activating OSD ID 5 FSID e06ae6d2-d881-40a0-adcd-2c55020474d5
Running command: /usr/bin/mount -t tmpfs tmpfs /var/lib/ceph/osd/ceph-5
--> Executable selinuxenabled not in PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-5
Running command: /usr/bin/ceph-bluestore-tool --cluster=ceph prime-osd-dir --dev /dev/ceph-8e2310de-b5ed-46bd-a32e-5048af46cfe0/osd-block-e06ae6d2-d881-40a0-adcd-2c55020474d5 --path /var/lib/ceph/osd/ceph-5 --no-mon-config
Running command: /usr/bin/ln -snf /dev/ceph-8e2310de-b5ed-46bd-a32e-5048af46cfe0/osd-block-e06ae6d2-d881-40a0-adcd-2c55020474d5 /var/lib/ceph/osd/ceph-5/block
Running command: /usr/bin/chown -h ceph:ceph /var/lib/ceph/osd/ceph-5/block
Running command: /usr/bin/chown -R ceph:ceph /dev/dm-2
Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-5
Running command: /usr/bin/systemctl enable ceph-volume@lvm-5-e06ae6d2-d881-40a0-adcd-2c55020474d5
 stderr: Created symlink /etc/systemd/system/multi-user.target.wants/ceph-volume@lvm-5-e06ae6d2-d881-40a0-adcd-2c55020474d5.service → /lib/systemd/system/ceph-volume@.service.
Running command: /usr/bin/systemctl enable --runtime ceph-osd@5
 stderr: Created symlink /run/systemd/system/ceph-osd.target.wants/ceph-osd@5.service → /lib/systemd/system/ceph-osd@.service.
Running command: /usr/bin/systemctl start ceph-osd@5
```

Next, lets check the status of our OSDs using `ceph osd tree`

``` bash
root@kube02:~# ceph osd tree
ID  CLASS  WEIGHT    TYPE NAME        STATUS  REWEIGHT  PRI-AFF
-1         14.84685  root default
-5          5.24072      host kube01
 4    ssd   0.87328          osd.4        up   1.00000  1.00000
 9    ssd   0.87328          osd.9        up   1.00000  1.00000
11    ssd   1.74709          osd.11       up   1.00000  1.00000
12    ssd   1.74709          osd.12       up   1.00000  1.00000
-7          3.49310      host kube02
 3    ssd   0.87328          osd.3      down   1.00000  1.00000
 5    ssd   0.87328          osd.5      down   1.00000  1.00000
 6    ssd   0.87328          osd.6      down   1.00000  1.00000
 7    ssd   0.87328          osd.7      down   1.00000  1.00000
-3          6.11302      host kube05
 0    ssd   0.87328          osd.0        up   1.00000  1.00000
 1    ssd   0.87328          osd.1        up   1.00000  1.00000
 2    ssd   0.87328          osd.2        up   1.00000  1.00000
 8    ssd   1.74660          osd.8        up   1.00000  1.00000
10    ssd   1.74660          osd.10       up   1.00000  1.00000
```

Oh, that is no good. They are still down. Lets fix that.

First- mark sure they are marked as up. (Use the number from the ID column in `ceph osd tree`)

``` bash
root@kube02:~# ceph osd in 3
marked in osd.3.
root@kube02:~# ceph osd in 5
marked in osd.5.
root@kube02:~# ceph osd in 6
marked in osd.6.
root@kube02:~# ceph osd in 7
marked in osd.7.
```

Next- try to start one.

``` bash
root@kube02:~# systemctl start ceph-osd@3
Job for ceph-osd@3.service failed because the control process exited with error code.
See "systemctl status ceph-osd@3.service" and "journalctl -xeu ceph-osd@3.service" for details.
```

Oops. That isn't good. Lets find out why.

``` bash
root@kube02:~# journalctl -xeu ceph-osd@3.service
░░ Support: https://www.debian.org/support
░░
░░ A start job for unit ceph-osd@3.service has finished successfully.
░░
░░ The job identifier is 8416.
Jun 12 21:16:12 kube02 ceph-osd[199292]: 2024-06-12T21:16:12.807-0500 7042e2cc56c0 -1 unable to find any IPv4 address in networks '10.100.6.105/24' interfaces ''
Jun 12 21:16:12 kube02 ceph-osd[199292]: 2024-06-12T21:16:12.807-0500 7042e2cc56c0 -1 Failed to pick cluster address.
Jun 12 21:16:12 kube02 systemd[1]: ceph-osd@3.service: Main process exited, code=exited, status=1/FAILURE
░░ Subject: Unit process exited
░░ Defined-By: systemd
░░ Support: https://www.debian.org/support
░░
░░ An ExecStart= process belonging to unit ceph-osd@3.service has exited.
░░
░░ The process' exit code is 'exited' and its exit status is 1.
Jun 12 21:16:12 kube02 systemd[1]: ceph-osd@3.service: Failed with result 'exit-code'.
░░ Subject: Unit failed
░░ Defined-By: systemd
░░ Support: https://www.debian.org/support
░░
░░ The unit ceph-osd@3.service has entered the 'failed' state with result 'exit-code'.
Jun 12 21:16:23 kube02 systemd[1]: ceph-osd@3.service: Scheduled restart job, restart counter is at 4.
░░ Subject: Automatic restarting of a unit has been scheduled
░░ Defined-By: systemd
░░ Support: https://www.debian.org/support
░░
░░ Automatic restarting of the unit ceph-osd@3.service has been scheduled, as the result for
░░ the configured Restart= setting for the unit.
Jun 12 21:16:23 kube02 systemd[1]: Stopped ceph-osd@3.service - Ceph object storage daemon osd.3.
░░ Subject: A stop job for unit ceph-osd@3.service has finished
░░ Defined-By: systemd
░░ Support: https://www.debian.org/support
░░
░░ A stop job for unit ceph-osd@3.service has finished.
░░
░░ The job identifier is 8927 and the job result is done.
Jun 12 21:16:23 kube02 systemd[1]: ceph-osd@3.service: Start request repeated too quickly.
Jun 12 21:16:23 kube02 systemd[1]: ceph-osd@3.service: Failed with result 'exit-code'.
░░ Subject: Unit failed
░░ Defined-By: systemd
░░ Support: https://www.debian.org/support
░░
░░ The unit ceph-osd@3.service has entered the 'failed' state with result 'exit-code'.
Jun 12 21:16:23 kube02 systemd[1]: Failed to start ceph-osd@3.service - Ceph object storage daemon osd.3.
░░ Subject: A start job for unit ceph-osd@3.service has failed
░░ Defined-By: systemd
░░ Support: https://www.debian.org/support
░░
░░ A start job for unit ceph-osd@3.service has finished with a failure.
░░
░░ The job identifier is 8927 and the job result is failed.
Jun 12 21:19:27 kube02 systemd[1]: ceph-osd@3.service: Start request repeated too quickly.
Jun 12 21:19:27 kube02 systemd[1]: ceph-osd@3.service: Failed with result 'exit-code'.
░░ Subject: Unit failed
░░ Defined-By: systemd
░░ Support: https://www.debian.org/support
░░
░░ The unit ceph-osd@3.service has entered the 'failed' state with result 'exit-code'.
Jun 12 21:19:27 kube02 systemd[1]: Failed to start ceph-osd@3.service - Ceph object storage daemon osd.3.
░░ Subject: A start job for unit ceph-osd@3.service has failed
░░ Defined-By: systemd
░░ Support: https://www.debian.org/support
░░
░░ A start job for unit ceph-osd@3.service has finished with a failure.
░░
░░ The job identifier is 9281 and the job result is failed.
```

Near the top of the output, you may have noticed this line: `unable to find any IPv4 address in networks '10.100.6.0/24' interfaces`

I have a dedicated non-routed layer 2 network specifically for ceph-traffic. It would seem, I need to go re-add that interface.

``` bash
nano /etc/network/interfaces

## Make your changes to the networking file

## And- then, reload networking
systemctl reload networking.service

```

If- after a few seconds, your bash prompt re-appears, its going to be a good day.

If not, and you messed up your networking configuration- your day just got a little bit longer.


In my case, I copied the networking file from one of my other hosts, as it has special bridge-vids, and settings for SDN (software defined networking). I updated the IP addresses, and network adapters, BUT, I forgot to update the vlan-raw-device under my vlan configuration. 

``` 
auto lo
iface lo inet loopback

auto eno1
#ConnectX-3 10G

iface eno1 inet manual
        mtu 1500

auto vmbr0
iface vmbr0 inet static
        address 10.100.4.102/24
        gateway 10.100.4.1
        bridge-ports eno1
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
        bridge-vids 2-15 100 4040

auto vlan6
iface vlan6 inet static
        address 10.100.6.102/24
        vlan-raw-device eno1      # <------ I forgot to update this
#V_STORAGE
source /etc/network/interfaces.d/*
```

At this point, lets go check our OSDs...

``` bash
root@kube02:~# ceph osd tree
ID  CLASS  WEIGHT    TYPE NAME        STATUS  REWEIGHT  PRI-AFF
-1         14.84685  root default
-5          5.24072      host kube01
 4    ssd   0.87328          osd.4        up   1.00000  1.00000
 9    ssd   0.87328          osd.9        up   1.00000  1.00000
11    ssd   1.74709          osd.11       up   1.00000  1.00000
12    ssd   1.74709          osd.12       up   1.00000  1.00000
-7          3.49310      host kube02
 3    ssd   0.87328          osd.3      down   1.00000  1.00000
 5    ssd   0.87328          osd.5      down   1.00000  1.00000
 6    ssd   0.87328          osd.6      down   1.00000  1.00000
 7    ssd   0.87328          osd.7      down   1.00000  1.00000
-3          6.11302      host kube05
 0    ssd   0.87328          osd.0        up   1.00000  1.00000
 1    ssd   0.87328          osd.1        up   1.00000  1.00000
 2    ssd   0.87328          osd.2        up   1.00000  1.00000
 8    ssd   1.74660          osd.8        up   1.00000  1.00000
10    ssd   1.74660          osd.10       up   1.00000  1.00000
``` 

Still down. Lets reset them, and try again.

``` bash
root@kube02:~# systemctl reset-failed ceph-osd@3.service
root@kube02:~# systemctl reset-failed ceph-osd@5.service
root@kube02:~# systemctl reset-failed ceph-osd@6.service
root@kube02:~# systemctl reset-failed ceph-osd@7.service
root@kube02:~# systemctl start ceph-osd@3.service
root@kube02:~# systemctl start ceph-osd@5.service
root@kube02:~# systemctl start ceph-osd@6.service
root@kube02:~# systemctl start ceph-osd@7.service
```

`ceph osd tree` won't update instantly. 

We can, check `journalctl -fe` for errors.

``` bash
root@kube02:~# journalctl -fe
...
Jun 12 21:30:12 kube02 systemd[1]: Starting ceph-osd@5.service - Ceph object storage daemon osd.5...
Jun 12 21:30:13 kube02 systemd[1]: Started ceph-osd@5.service - Ceph object storage daemon osd.5.
Jun 12 21:30:13 kube02 systemd[1]: Starting ceph-osd@6.service - Ceph object storage daemon osd.6...
Jun 12 21:30:15 kube02 systemd[1]: Started ceph-osd@6.service - Ceph object storage daemon osd.6.
Jun 12 21:30:16 kube02 systemd[1]: Starting ceph-osd@7.service - Ceph object storage daemon osd.7...
Jun 12 21:30:17 kube02 systemd[1]: Started ceph-osd@7.service - Ceph object storage daemon osd.7.
...
```

No errors, should be all good.

``` bash
# After a few moments... we had one OSD up.
root@kube02:~# ceph osd tree
ID  CLASS  WEIGHT    TYPE NAME        STATUS  REWEIGHT  PRI-AFF
-1         14.84685  root default
-5          5.24072      host kube01
 4    ssd   0.87328          osd.4        up   1.00000  1.00000
 9    ssd   0.87328          osd.9        up   1.00000  1.00000
11    ssd   1.74709          osd.11       up   1.00000  1.00000
12    ssd   1.74709          osd.12       up   1.00000  1.00000
-7          3.49310      host kube02
 3    ssd   0.87328          osd.3      down         0  1.00000
 5    ssd   0.87328          osd.5      down         0  1.00000
 6    ssd   0.87328          osd.6      down         0  1.00000
 7    ssd   0.87328          osd.7        up   1.00000  1.00000
-3          6.11302      host kube05
 0    ssd   0.87328          osd.0        up   1.00000  1.00000
 1    ssd   0.87328          osd.1        up   1.00000  1.00000
 2    ssd   0.87328          osd.2        up   1.00000  1.00000
 8    ssd   1.74660          osd.8        up   1.00000  1.00000
10    ssd   1.74660          osd.10       up   1.00000  1.00000

## And- after a couple of minutes, everything was up.
root@kube02:~# ceph osd tree
ID  CLASS  WEIGHT    TYPE NAME        STATUS  REWEIGHT  PRI-AFF
-1         14.84685  root default
-5          5.24072      host kube01
 4    ssd   0.87328          osd.4        up   1.00000  1.00000
 9    ssd   0.87328          osd.9        up   1.00000  1.00000
11    ssd   1.74709          osd.11       up   1.00000  1.00000
12    ssd   1.74709          osd.12       up   1.00000  1.00000
-7          3.49310      host kube02
 3    ssd   0.87328          osd.3        up   1.00000  1.00000
 5    ssd   0.87328          osd.5        up   1.00000  1.00000
 6    ssd   0.87328          osd.6        up   1.00000  1.00000
 7    ssd   0.87328          osd.7        up   1.00000  1.00000
-3          6.11302      host kube05
 0    ssd   0.87328          osd.0        up   1.00000  1.00000
 1    ssd   0.87328          osd.1        up   1.00000  1.00000
 2    ssd   0.87328          osd.2        up   1.00000  1.00000
 8    ssd   1.74660          osd.8        up   1.00000  1.00000
10    ssd   1.74660          osd.10       up   1.00000  1.00000
```

At this point, check `ceph status` If you want to watch the output as it heals up, you can use `ceph status -w` to watch the output.

``` bash
root@kube02:~# ceph status -w
  cluster:
    id:     016d27bb-5e11-4c85-846a-98f1f0b7ec08
    health: HEALTH_WARN
            Degraded data redundancy: 288792/1798224 objects degraded (16.060%), 61 pgs degraded, 42 pgs undersized

  services:
    mon: 2 daemons, quorum kube05,kube01 (age 3h)
    mgr: kube05(active, since 5h), standbys: kube01
    mds: 1/1 daemons up, 1 standby
    osd: 13 osds: 13 up (since 61s), 13 in (since 61s); 61 remapped pgs

  data:
    volumes: 1/1 healthy
    pools:   5 pools, 129 pgs
    objects: 599.41k objects, 1.3 TiB
    usage:   3.8 TiB used, 11 TiB / 15 TiB avail
    pgs:     288792/1798224 objects degraded (16.060%)
             68 active+clean
             39 active+undersized+degraded+remapped+backfill_wait
             20 active+recovery_wait+undersized+degraded+remapped
             2  active+recovering+undersized+degraded+remapped

  io:
    client:   328 KiB/s rd, 1.9 MiB/s wr, 83 op/s rd, 154 op/s wr
    recovery: 21 MiB/s, 59 objects/s


2024-06-12T21:33:54.022362-0500 mon.kube05 [WRN] Health check update: Degraded data redundancy: 288765/1798227 objects degraded (16.058%), 61 pgs degraded, 61 pgs undersized (PG_DEGRADED)
2024-06-12T21:33:59.025195-0500 mon.kube05 [WRN] Health check update: Degraded data redundancy: 288407/1798227 objects degraded (16.038%), 60 pgs degraded, 60 pgs undersized (PG_DEGRADED)
2024-06-12T21:34:04.030359-0500 mon.kube05 [WRN] Health check update: Degraded data redundancy: 288263/1798227 objects degraded (16.030%), 60 pgs degraded, 60 pgs undersized (PG_DEGRADED)
2024-06-12T21:34:09.033479-0500 mon.kube05 [WRN] Health check update: Degraded data redundancy: 287886/1798227 objects degraded (16.009%), 60 pgs degraded, 60 pgs undersized (PG_DEGRADED)
2024-06-12T21:34:14.037276-0500 mon.kube05 [WRN] Health check update: Degraded data redundancy: 287654/1798230 objects degraded (15.997%), 59 pgs degraded, 59 pgs undersized (PG_DEGRADED)
2024-06-12T21:34:19.040047-0500 mon.kube05 [WRN] Health check update: Degraded data redundancy: 287336/1798230 objects degraded (15.979%), 59 pgs degraded, 59 pgs undersized (PG_DEGRADED)
2024-06-12T21:34:24.043003-0500 mon.kube05 [WRN] Health check update: Degraded data redundancy: 287029/1798251 objects degraded (15.962%), 58 pgs degraded, 58 pgs undersized (PG_DEGRADED)
2024-06-12T21:34:29.047180-0500 mon.kube05 [WRN] Health check update: Degraded data redundancy: 286728/1798263 objects degraded (15.945%), 58 pgs degraded, 58 pgs undersized (PG_DEGRADED)
```

The important thing to look for in this output- is the services section.

Make sure you have mons up, and quorum is established.

Make sure you a mgr up.

And, make sure all of your osds are up.

Otherwise, ceph will scan the OSDs, make changes as needed, and self-heal.

#### Step 9. Re-import SDN

If, you use [Proxmox's SDN Features](https://pve.proxmox.com/pve-docs/chapter-pvesdn.html){target=_blank}, there is a good chance this will not be applied to your node currently.

To correct this, you can do one of two things.

1. Make a change in your SDN configuration, which will cause the new install to receive the update.
2. OR, run this command: `pvesh set /nodes/$(hostname)/network`

``` bash
root@kube02:~# pvesh set /nodes/$(hostname)/network
info: executing /usr/bin/dpkg -l ifupdown2
UPID:kube02:0003BA42:00137BD5:666A5E7A:srvreload:networking:root@pam:
```

Afterwards, all of your SDN configurations will be reapplied.


## Summary

If- you are going through this process- hopefully the above documentation should save you a lot of time.

It personally took me two or three hours to get this node fully back online and functional, as these steps, aren't really documented anywhere I could find.

A few random links which were less then helpful...

- https://forum.proxmox.com/threads/backup-pve-host-and-restore-to-new-disk.129839/
    * Nothing of use in here
- https://www.reddit.com/r/Proxmox/comments/105jqwp/backing_up_proxmox_host/
    * nothing of use in here either.
- https://forum.proxmox.com/threads/backup-restore-procedure-for-proxmox-ve-host.118264/
- https://forum.proxmox.com/threads/how-to-restore-pve-host.139585/
    * had a few good pointers
- https://pve.proxmox.com/wiki/Proxmox_Cluster_File_System_(pmxcfs)#_recovery
    * useless
- https://pbs.proxmox.com/docs/backup-client.html#creating-backups
    * Also, useless. (There is no documentation on how to restore a host from PBS either!)

So- on that note, enjoy the first actual documentation (that I could find) on how to successfully reinstall a failed cluster node, and re-importing its configuration.

I will note, this also validates that my backup strategy of backing up the `/etc/pve` directory from a single host, is adequate for doing a cluster recovery, if needed.

