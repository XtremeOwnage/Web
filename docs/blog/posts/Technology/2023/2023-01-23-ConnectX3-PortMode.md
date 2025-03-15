---
title: "ConnectX-3 Set Port Mode to ETH/IB"
date: 2023-01-23
tags:
  - Homelab
  - Networking/Mellanox
---

# ConnectX-3 Set Port Mode to ETH/IB

I just swapped my TrueNAS from a [Dell R720XD](2023-01-13-r720xd-death.md) over to a Dell r730XD. During this migration, I moved over my NVMe drives, NICs, and everything else relevant.

However, after firing up TrueNAS on the new hardware, I noticed my 40G NIC was not listed in the list of devices!

After once again googling how to change the mode over, I figured I would just quickly write some documentation incase this happens again in the future.

<!-- more -->

## Depreciated!!!!

!!! warn
        A newer version of this post is available now.

[See: ConnectX Guide](../2025/ConnectX-Helpers.md)

## Why would you change this?

Mellanox NICs can support traffic in either Ethernet mode, or Infiniband Mode. 

In ethernet mode, they function exactly like you would expect a NIC to work. However, in Infiniband mode, they work quite a bit different, and may require special drivers and software to perform correctly.

For most homelab uses, you will generally want to ensure they are configured to ethernet mode.

## How to change port mode of ConnectX-3 NIC

### Step 1. Determine the PCI ID.

You can do this using `lspci`

``` bash
root@truenas:~# lspci | grep Mell
09:00.0 Network controller: Mellanox Technologies MT27500 Family [ConnectX-3]
```

In the above case, `09:00.0` is the information we are looking for.

### Step 2. Determine current port mode.

``` bash
root@truenas:~# cat /sys/bus/pci/devices/0000\:09\:00.0/mlx4_port1
ib
root@truenas:~# cat /sys/bus/pci/devices/0000\:09\:00.0/mlx4_port2
eth
```

Using the above command, we can determine port1 is in infiniband mode, and port2 is in ethernet mode.

### Step 3. How to change port mode.

There are two ways you can change the port mode. You can either.... use a simple echo command, or, you can use mstflint.

#### Method 1. Using echo.

``` bash
root@truenas:~# echo eth > /sys/bus/pci/devices/0000\:09\:00.0/mlx4_port1
-bash: echo: write error: Operation not supported

root@truenas:~# echo ib > /sys/bus/pci/devices/0000\:09\:00.0/mlx4_port1

# Works fine?
```

IF, this option does not work for you, then try using mstflint. If it does work (no error), reboot for it to take effect.

#### Method 2. Using mstflint.

`apt-get install mstflint`

Note- if you use TrueNAS like me... you may need to [Re-enable apt-get](../2022/2022-03-26-TrueNAS-Reenable-apt-get.md){target=_blank}

Then use `mstflint -d {your pci id} q` to query info

``` bash
root@truenas:~# mstconfig -d 09:00.0 q

Device #1:
----------

Device type:    ConnectX3
Device:         09:00.0

Configurations:                              Next Boot
         SRIOV_EN                            True(1)
         NUM_OF_VFS                          8
         LINK_TYPE_P1                        IB(1)
         LINK_TYPE_P2                        ETH(2)
         LOG_BAR_SIZE                        3
         BOOT_PKEY_P1                        0
         BOOT_PKEY_P2                        0
         BOOT_OPTION_ROM_EN_P1               False(0)
         BOOT_VLAN_EN_P1                     False(0)
         BOOT_RETRY_CNT_P1                   0
         LEGACY_BOOT_PROTOCOL_P1             PXE(1)
         BOOT_VLAN_P1                        1
         BOOT_OPTION_ROM_EN_P2               False(0)
         BOOT_VLAN_EN_P2                     False(0)
         BOOT_RETRY_CNT_P2                   0
         LEGACY_BOOT_PROTOCOL_P2             PXE(1)
         BOOT_VLAN_P2                        1
         IP_VER_P1                           IPv4(0)
         IP_VER_P2                           IPv4(0)
         CQ_TIMESTAMP                        True(1)
```

For the `LINK_TYPE` fields, IB/1 = infiniband, ETH/2 = ethernet

To change the mode, we can use `mstconfig -d 09:00.0 set LINK_TYPE_P1=2`, Just make sure to replace with your PCI device id.

``` bash
root@truenas:~# mstconfig -d 09:00.0 set LINK_TYPE_P1=2

Device #1:
----------

Device type:    ConnectX3
Device:         09:00.0

Configurations:                              Next Boot       New
         LINK_TYPE_P1                        IB(1)           ETH(2)

 Apply new Configuration? (y/n) [n] : y
Applying... Done!
-I- Please reboot machine to load new configurations.
```

Per the note- you will need to reboot before this takes effect.


## Summary

Just a quick guide on how to change the port mode of your ConnectX-3 NICs. This works for both the 10G and 40G variants.

Also- the port-mode wasn't the issue as to why it wasn't being displayed- Instead- the NIC was at a differnet PCI address location. I just needed to move over the config. :-/