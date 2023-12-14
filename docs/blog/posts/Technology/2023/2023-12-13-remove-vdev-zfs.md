---
title: "Removing Stripe from ZFS Pool"
date: 2023-12-13
tags:
  - Homelab
  - Storage
---

# Removing a stripe from a zfs pool

In my quest to optimize on power usage, One of my servers has a zfs pool consisting of 4x 8T disks, in striped mirrors configuration.

For this particular pool, IOPs and performance is not needed. As well, I am using barely 10% of the available space in this particular pool.

So- I decided to remove a pair of disks, to save a miniscule amount of energy.

<!-- more -->

!!! danger
    These steps are intended for openzfs.

    Also- I am not responsible for data loss. Don't perform actions on your pool, without tested, working backups.

    (Snapshots / Raid) is not backups.

## Step 1. Identify your pool

`zpool status` can be used to identify your pool, and its vdevs.

``` bash
root@Tower:~# zpool status
  pool: cache
 state: ONLINE
  scan: resilvered 1.59M in 00:00:00 with 0 errors on Wed Dec 13 19:09:21 2023
config:

        NAME           STATE     READ WRITE CKSUM
        cache          ONLINE       0     0     0
          mirror-0     ONLINE       0     0     0
            nvme2n1p1  ONLINE       0     0     0
            nvme1n1p1  ONLINE       0     0     0
          mirror-1     ONLINE       0     0     0
            nvme0n1p1  ONLINE       0     0     0
            nvme3n1p1  ONLINE       0     0     0

errors: No known data errors

  pool: main
 state: ONLINE
  scan: scrub repaired 0B in 01:47:49 with 0 errors on Sun Dec 10 11:47:50 2023
config:

        NAME        STATE     READ WRITE CKSUM
        main        ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdc1    ONLINE       0     0     0
            sdf1    ONLINE       0     0     0
          mirror-1  ONLINE       0     0     0
            sdg1    ONLINE       0     0     0
            sdi1    ONLINE       0     0     0
```

In my case, I want to remove the `mirror-1` vdev from the `main` pool.


## Step 2. Remove the vdev

Removing a top-level vdev is easy to do.

`zpool remove main mirror-1`

Where the syntax is- zpool remove pool-name vdev-name

Documentation for this command [Can be found on the openzfs github](https://openzfs.github.io/openzfs-docs/man/master/8/zpool-remove.8.html){target=_blank}

Running this command will not yield any output. However, you can view the current progress using `zpool status`

``` bash
root@Tower:~# zpool status
  pool: cache
 state: ONLINE
  scan: resilvered 1.59M in 00:00:00 with 0 errors on Wed Dec 13 19:09:21 2023
config:

        NAME           STATE     READ WRITE CKSUM
        cache          ONLINE       0     0     0
          mirror-0     ONLINE       0     0     0
            nvme2n1p1  ONLINE       0     0     0
            nvme1n1p1  ONLINE       0     0     0
          mirror-1     ONLINE       0     0     0
            nvme0n1p1  ONLINE       0     0     0
            nvme3n1p1  ONLINE       0     0     0

errors: No known data errors

  pool: main
 state: ONLINE
  scan: scrub repaired 0B in 01:47:49 with 0 errors on Sun Dec 10 11:47:50 2023
remove: Evacuation of mirror in progress since Wed Dec 13 21:18:05 2023
        6.06G copied out of 940G at 98.6M/s, 0.64% done, 2h41m to go
config:

        NAME        STATE     READ WRITE CKSUM
        main        ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdc1    ONLINE       0     0     0
            sdf1    ONLINE       0     0     0
          mirror-1  ONLINE       0     0     0
            sdg1    ONLINE       0     0     0
            sdi1    ONLINE       0     0     0

errors: No known data errors
```

At this point, you just need to wait for the pool to finish moving data around.

It will yield the estimated time, and once completed, the vdev will be removed.