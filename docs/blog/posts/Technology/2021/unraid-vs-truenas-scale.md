---
title: "Unraid Vs TrueNAS SCALE 2021"
date: 2021-11-10
tags:
  - TrueNAS
  - Homelab
---

# Unraid Vs TrueNAS SCALE 2021

Often, I see a bunch of posts where someone is having a tough time considering between Unraid, or TrueNAS. so, I am going to write a quick summary based on my experiences, and recommendations.

<!-- more -->

This article is basically copied from my [comment](https://www.reddit.com/r/truenas/comments/qnjyp0/comment/hjgqjpc/?utm_source=share&utm_medium=web2x&context=3){target=_blank} on reddit.

### Unraid

#### Pros

- **Disk Management:** You add disks, you gain storage, simple as that.
- **Write Caching:** Its method of write caching allows adding NVMe to a dedicated flash pool, enhancing performance.
- **Resources:** Doesn't require many resources to run a decently performant install.
- **UI:** Unraid has a fantastic UI that is very easy to use and navigate.
- **Power Usage:** Only the drive containing the file you are using needs to be spun up.
- **Tiered Storage:** Provides a rudimentary system of tiered storage.

#### Cons

- **Performance:** Unless your data lives on your flash cache, you are limited to the performance of a single drive.

### TrueNAS

#### Pros

- **Storage Expansion:** Adding storage means adding another vdev. In the future, online expansion will be added.
- **Performance:** Data is read from and written to all disks in a vdev simultaneously.
- **UI:** Scale is still in beta with bugs being worked out. The UI doesn't compare to Unraid's ease of use.

#### Cons

- **Resources:** Requires ample RAM, especially ECC RAM.
- **Power Usage:** When you read or write something, your entire array has to spin up.
- **Tiered Storage:** Non-existent in TrueNAS.

## Which is Better?

Neither. Each one fits into a unique niche. For a recommendation, specific needs should be considered.

- **Unraid:** Suitable for non-technical users who want a NAS that "just works" with its simplistic UI and easy storage expansion.
- **TrueNAS:** Better for technical users who don't mind tinkering, offering excellent performance and reliability with proper hardware.

## Which One is Faster?

Neither. Each has its strengths. TrueNAS excels in spinning disk array performance, while Unraid minimizes bottlenecks with NVMe caching.

## Personal Choice

I prefer TrueNAS for its performance, reliability, and control over data management.

Seriously, both are good platforms to choose from.



## Update from 2024-

Since, this post was migrated from the old site, to this new static site- Just adding a quick update.

As of 2024, I no longer utilize TrueNAS Scale. I do, however continue to run Unraid. 

Since- Unraid added native ZFS, this handles the one downside I originally had with Unraid. 

As well- it offers a lot more flexibility in terms of storage support. 