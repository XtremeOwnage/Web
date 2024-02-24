---
title: "Reattaching NVMe from VFIO"
date: 2024-02-24
tags:
  - Homelab
  - Storage
  - Proxmox
---

# Proxmox - Reattach NVMe previous bound by VFIO

So, I have a VM on proxmox, which has 4 individual NVMe drives directly passed in. 

I wanted to attach one of those drives to another VM. 

This is a very short guide on how to unbind the NVMe from vfio, and re-attach it to the hypervisor.

<!-- more -->

## Steps

### 1. Identify the drive

In my case, I am looking for a 1T Samsung 970 evo.

However, looking at the drive from the hypervisor, shows that it is still bound by VFIO, despite being removed from the VM.

``` bash
root@kube02:~# lshw -class storage
  *-nvme
       description: Non-Volatile memory controller
       product: NVMe SSD Controller SM981/PM981/PM983
       vendor: Samsung Electronics Co Ltd
       physical id: 0
       bus info: pci@0000:84:00.0
       version: 00
       width: 64 bits
       clock: 33MHz
       capabilities: nvme pm msi pciexpress msix nvm_express cap_list
       configuration: driver=vfio-pci latency=0
       resources: irq:82 memory:c8600000-c8603fff
```

Since, it is currently bound to the VFIO driver, we cannot currently use it with the host.

### Step 2. Release the device from VFIO.

After googling this issue myself, I found lots of guides on the internet telling me to unload the vfio modules. 

You do not want to do this, as it will potentially break all of your other VMs with device passthrough.

Instead, we can unbind a single device.

``` echo "0000:84:00.0" > /sys/bus/pci/devices/0000:84:00.0/driver/unbind ```

Now, we can bind it to the nvme driver.

``` echo "0000:84:00.0" > /sys/bus/pci/drivers/nvme/bind ```

### Step 3. Done.

As you can see, the NVMe is now usable by the host.

``` bash
root@kube02:~# lsblk
NAME                                                                                                  MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nvme1n1                                                                                               259:8    0 931.5G  0 disk
└─nvme1n1p1
```


``` bash
root@kube02:~# lshw -class storage
  *-nvme
       description: NVMe device
       product: Samsung SSD 970 EVO 1TB
       vendor: Samsung Electronics Co Ltd
       physical id: 0
       bus info: pci@0000:84:00.0
       logical name: /dev/nvme1
       version: 2B2QEXE7
       serial: S5H9NS0NA99060M
       width: 64 bits
       clock: 33MHz
       capabilities: nvme pm msi pciexpress msix nvm_express bus_master cap_list
       configuration: driver=nvme latency=0 nqn=nqn.2014.08.org.nvmexpress:144d144dS5H9NS0NA99060M     Samsung SSD 970 EVO 1TB state=live
       resources: irq:365 memory:c8600000-c8603fff
```