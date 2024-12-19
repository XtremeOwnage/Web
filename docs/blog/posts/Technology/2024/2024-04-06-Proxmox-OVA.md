---
title: "Proxmox - Import OVA"
date: 2024-04-08
tags:
  - Homelab
  - Proxmox
---

# Proxmox - Import OVA

A random thing I recently came across while testing out LibreNMS- 

I discovered they have a published .ova, which I wanted to import into Proxmox. However, proxmox as of this post, does not have a easy option to support importing this.

This- is a quick post, containing the commands you need, to import the ova.

<!-- more -->

## Steps

### 1. Download the .ova

First- download the ova onto one of your proxmox nodes.

`wget https://github.com/librenms/packer-builds/releases/download/23.11.0/librenms-ubuntu-22.04-amd64-vmware.ova`

### 2. Extract the .ova, into a .ovf

A .ova is just a tar archive, with a few extra things.

`tar -xf librenms-ubuntu-22.04-amd64-vmware.ova`

### 3. Import the .ovf

The format of the command-

qm importovf VM-ID OVF-FILE YOUR-STORAGE

135 is the next free ID I have, so I will use this.

We will use the .ovf we got from extracting the .ova above.

Finally- we need to pick the target storage for the new VM.

If- you don't know which storage, or the name of your storage, you can use `pvesm status` to list the available storages.

```
root@kube02:~# pvesm status
Name               Type     Status           Total            Used       Available        %
GameStorage     zfspool     active       942931968       294817116       648114852   31.27%
ISOs                nfs     active     15512513536      3881544704     11630968832   25.02%
Unraid              nfs     active     15512513536      3881544704     11630968832   25.02%
ceph-block          rbd     active      3670495077       571569765      3098925312   15.57%
local               dir     active        98497780        11778920        81669312   11.96%
```

I will be choosing ceph-block storage.

Here is the resulting command

`qm importovf 135 librenms-ubuntu-22.04-amd64-vmware.ovf ceph-block`

```
root@kube02:~# qm importovf 135 librenms-ubuntu-22.04-amd64-vmware.ovf ceph-block
transferred 0.0 B of 40.0 GiB (0.00%)
transferred 409.6 MiB of 40.0 GiB (1.00%)
transferred 819.2 MiB of 40.0 GiB (2.00%)
transferred 1.2 GiB of 40.0 GiB (3.00%)
...
transferred 40.0 GiB of 40.0 GiB (100.00%)
transferred 40.0 GiB of 40.0 GiB (100.00%)
```

After this is done, you will have a new VM created. You can view and manage this VM using the web interface.