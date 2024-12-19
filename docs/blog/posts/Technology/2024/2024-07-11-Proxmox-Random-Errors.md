---
title: "Proxmox - Random Error Fixes"
date: 2024-07-11
tags:
  - Homelab
  - Proxmox
---

# Proxmox - Solutions to random errors.

This- is a short post which details how to resolve a few random errors you may experience with proxmox.

This post is for you, IF, you are experiencing any of these errors:

* "System booted in EFI-mode but 'grub-efi-amd64' meta-package not installed! Install 'grub-efi-amd64' to get updates."
* "Couldn't find EFI system partition. It is recommended to mount it to /boot or /efi."
* "/etc/kernel/proxmox-boot-uuids does not exist."

<!-- more -->


### "System booted in EFI-mode but 'grub-efi-amd64' meta-package not installed! Install 'grub-efi-amd64' to get updates."

Apparently some of the older versions of the proxmox installer included the incorrect package of `grub-pc` instead of `grub-efi-amd64`

You can run `apt-get install grub-efi-amd64` to correct this, and it will automatically remove the old package.

``` bash
root@kube01:~# apt-get install grub-efi-amd64
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following package was automatically installed and is no longer required:
  proxmox-kernel-6.5.11-8-pve-signed
Use 'apt autoremove' to remove it.
The following packages will be REMOVED:
  grub-pc
The following NEW packages will be installed:
  grub-efi-amd64
0 upgraded, 1 newly installed, 1 to remove and 22 not upgraded.
Need to get 45.7 kB of archives.
After this operation, 384 kB disk space will be freed.
Do you want to continue? [Y/n]
```

More references:

1. <https://forum.proxmox.com/threads/pve-7-3-3-configuring-grub-pc-grub-failed-to-install-to-the-following-devices.123395/>
2. <https://forum.proxmox.com/threads/update-installed-system-booted-in-efi-mode-but-grub-efi-amd64-meta-package-not-installed.137324/>

### "Couldn't find EFI system partition. It is recommended to mount it to /boot or /efi."

This error is encountered when trying to `update-initramfs`

``` bash
root@kube01:~# update-initramfs -u -k all
update-initramfs: Generating /boot/initrd.img-6.8.4-2-pve
Running hook script 'zz-proxmox-boot'..
Re-executing '/etc/kernel/postinst.d/zz-proxmox-boot' in new private mount namespace..
No /etc/kernel/proxmox-boot-uuids found, skipping ESP sync.
System booted in EFI-mode but 'grub-efi-amd64' meta-package not installed!
Install 'grub-efi-amd64' to get updates.
Couldn't find EFI system partition. It is recommended to mount it to /boot or /efi.
Alternatively, use --esp-path= to specify path to mount point.
update-initramfs: Generating /boot/initrd.img-6.5.13-5-pve
Running hook script 'zz-proxmox-boot'..
Re-executing '/etc/kernel/postinst.d/zz-proxmox-boot' in new private mount namespace..
No /etc/kernel/proxmox-boot-uuids found, skipping ESP sync.
System booted in EFI-mode but 'grub-efi-amd64' meta-package not installed!
Install 'grub-efi-amd64' to get updates.
Couldn't find EFI system partition. It is recommended to mount it to /boot or /efi.
Alternatively, use --esp-path= to specify path to mount point.
update-initramfs: Generating /boot/initrd.img-6.5.11-8-pve
Running hook script 'zz-proxmox-boot'..
Re-executing '/etc/kernel/postinst.d/zz-proxmox-boot' in new private mount namespace..
No /etc/kernel/proxmox-boot-uuids found, skipping ESP sync.
System booted in EFI-mode but 'grub-efi-amd64' meta-package not installed!
Install 'grub-efi-amd64' to get updates.
Couldn't find EFI system partition. It is recommended to mount it to /boot or /efi.
Alternatively, use --esp-path= to specify path to mount point.
update-initramfs: Generating /boot/initrd.img-6.2.16-20-pve
^C
```


First- verify we are booted in EFI mode. (If, you see results in this directory- you are in EFI mode.)

``` bash
root@kube01:~# ls /sys/firmware/efi
config_table  efivars  esrt  fw_platform_size  fw_vendor  runtime  runtime-map  systab
```

Next- identify the "root" drive. Based on the `lsblk` results below, the primary drive is `/dev/nvme0n1`

``` bash
root@kube01:~# lsblk
NAME                                                                                                  MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda                                                                                                     8:0    0   1.7T  0 disk
└─ceph--94463e67--18fb--4b29--9e62--d3c40652cf14-osd--block--2ca45b36--0ca1--42e5--b66e--34f98dda21ca 252:0    0   1.7T  0 lvm
sdb                                                                                                     8:16   0   1.7T  0 disk
└─ceph--e7e5f5f3--fd44--46e6--bc71--c0c6343efd5e-osd--block--8930211c--aec9--4fde--86dd--b39ba42c7787 252:3    0   1.7T  0 lvm
sdc                                                                                                     8:32   0 894.3G  0 disk
└─ceph--03215be4--5055--4eb3--bc93--5e342cf7f9ea-osd--block--85e1beb9--a39e--46db--94db--61fe404ed0fb 252:2    0 894.3G  0 lvm
sdd                                                                                                     8:48   0 894.3G  0 disk
└─ceph--853aa98b--2aa5--4e7b--b411--5a737f80cffd-osd--block--5b3420a5--9e3b--4217--b27a--b236121e3e1a 252:1    0 894.3G  0 lvm
sr0                                                                                                    11:0    1  1024M  0 rom
nvme0n1                                                                                               259:0    0 119.2G  0 disk
├─nvme0n1p1                                                                                           259:1    0  1007K  0 part
├─nvme0n1p2                                                                                           259:2    0     1G  0 part
└─nvme0n1p3                                                                                           259:3    0 118.2G  0 part
  ├─pve-swap                                                                                          252:4    0     8G  0 lvm  [SWAP]
  ├─pve-root                                                                                          252:5    0  39.6G  0 lvm  /
  ├─pve-data_tmeta                                                                                    252:6    0     1G  0 lvm
  │ └─pve-data                                                                                        252:8    0  53.9G  0 lvm
  └─pve-data_tdata                                                                                    252:7    0  53.9G  0 lvm
    └─pve-data                                                                                        252:8    0  53.9G  0 lvm
```

List the partitions for the drive identified above, using `fdisk -l /dev/your-device`

``` bash
root@kube01:~# fdisk -l /dev/nvme0n1
Disk /dev/nvme0n1: 119.24 GiB, 128035676160 bytes, 250069680 sectors
Disk model: KBG40ZNS128G NVMe KIOXIA 128GB
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: D59D0401-0022-4F68-8D7A-D6C0CD8F1EA4

Device           Start       End   Sectors   Size Type
/dev/nvme0n1p1      34      2047      2014  1007K BIOS boot
/dev/nvme0n1p2    2048   2099199   2097152     1G EFI System
/dev/nvme0n1p3 2099200 250069646 247970447 118.2G Linux LVM
```

So- /dev/nvme0n1p2 contains the EFI system. Mount it.

``` bash
root@kube01:~# mount /dev/nvme0n1p2 /boot/efi
```

### "/etc/kernel/proxmox-boot-uuids does not exist."

First, verify this is your issue-

``` bash
root@kube01:~# proxmox-boot-tool status
Re-executing '/usr/sbin/proxmox-boot-tool' in new private mount namespace..
E: /etc/kernel/proxmox-boot-uuids does not exist.
```

Unmount `/boot/efi`

``` bash
umount /boot/efi
```

And.... run `proxmox-boot-tool init /dev/your-efi-drive-partition`

``` bash
root@kube01:~# proxmox-boot-tool init /dev/nvme0n1p2
Re-executing '/usr/sbin/proxmox-boot-tool' in new private mount namespace..
UUID="D34B-A25D" SIZE="1073741824" FSTYPE="vfat" PARTTYPE="c12a7328-f81f-11d2-ba4b-00a0c93ec93b" PKNAME="nvme0n1" MOUNTPOINT=""
Mounting '/dev/nvme0n1p2' on '/var/tmp/espmounts/D34B-A25D'.
Installing grub x86_64 target..
Installing for x86_64-efi platform.
Installation finished. No error reported.
Installing grub x86_64 target (removable)..
Installing for x86_64-efi platform.
Installation finished. No error reported.
Unmounting '/dev/nvme0n1p2'.
Adding '/dev/nvme0n1p2' to list of synced ESPs..
Refreshing kernels and initrds..
Running hook script 'proxmox-auto-removal'..
Running hook script 'zz-proxmox-boot'..
No /etc/kernel/cmdline found - falling back to /proc/cmdline
Copying and configuring kernels on /dev/disk/by-uuid/D34B-A25D
        Copying kernel 6.5.13-5-pve
        Copying kernel 6.8.4-2-pve
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.8.4-2-pve
Found initrd image: /boot/initrd.img-6.8.4-2-pve
Found linux image: /boot/vmlinuz-6.5.13-5-pve
Found initrd image: /boot/initrd.img-6.5.13-5-pve
Adding boot menu entry for UEFI Firmware Settings ...
done
        Disabling upstream hook /etc/initramfs/post-update.d/systemd-boot
        Disabling upstream hook /etc/kernel/postinst.d/zz-systemd-boot
        Disabling upstream hook /etc/kernel/postrm.d/zz-systemd-boot
```

Afterwards, you should be good to go.

``` bash
root@kube01:~# proxmox-boot-tool status
Re-executing '/usr/sbin/proxmox-boot-tool' in new private mount namespace..
System currently booted with uefi
D34B-A25D is configured with: grub (versions: 6.8.4-3-pve, 6.8.8-2-pve)
```