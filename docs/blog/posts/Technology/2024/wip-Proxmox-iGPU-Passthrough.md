## Proxmox - SR-IOV, and IOMMU for iGPU/GPU/NIC Passthrough to VMs


Make sure your CPU supports IOMMU.

https://en.wikipedia.org/wiki/List_of_IOMMU-supporting_hardware

Proxmox Docs

https://pve.proxmox.com/wiki/PCI(e)_Passthrough


### Before actually starting...

##### Clear old kernel versions

My proxmox has bene running for a few years at this point, and this particular host, has a LOT of old kernel versions hanging around.

Here- is a list of the version I had hanging around-

- proxmox-kernel-6.2.16-8-pve
- proxmox-kernel-6.2.16-15-pve
- proxmox-kernel-6.2.16-19-pve
- proxmox-kernel-6.2.16-20-pve
- proxmox-kernel-6.5.11-4-pve-signed
- proxmox-kernel-6.5.11-7-pve-signed
- proxmox-kernel-6.5.11-8-pve-signed
- proxmox-kernel-6.5.13-5-pve-signed
- pve-kernel-6.2.16-3-pve
- pve-kernel-6.2.16-4-pve
- pve-kernel-6.2.16-5-pve

Keeping- these old kernel versions, will make the following.... steps take much longer...

Here, is a simplified script when can be pasted directly into bash, to automatically clean up your old kernel versions.

If, you want a slightly more elegant solution, you can use the [Original TTECK script](https://tteck.github.io/Proxmox/#proxmox-ve-kernel-clean){target=_blank} that the below script is based on.

``` bash
#!/usr/bin/env bash

# Get current and available kernels
current_kernel=$(uname -r)
available_kernels=$(dpkg --list | grep 'kernel-.*-pve' | awk '{print $2}' | grep -v "$current_kernel" | sort -V)

# Check if there are any old kernels
if [ -z "$available_kernels" ]; then
  echo "No old kernels to remove. Current kernel: $current_kernel."
  exit 0
fi

# Function to remove kernels
remove_kernels() {
  for kernel in $available_kernels; do
    /usr/bin/apt purge -y "$kernel"
  done
}

# Remove old kernels
remove_kernels

# Update GRUB
/usr/sbin/update-grub

echo "Successfully removed old kernels and updated GRUB."
```

##### Update packages

Run `apt-get update && apt-get dist-upgrade`

Since- we will be updating the kernel, and rebooting, you might as well install patches, and upgrade your kernel now.


### Updating boot / kernel options....

#### Update kernel IOMMU settings

Edit /etc/default/grub

FIND GRUB_CMDLINE_LINUX_DEFAULT, ADD "intel_iommu=on iommu=pt"

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt"
```

#### Add vfio kernel modules.

EDIT `/etc/modules`

ADD

```
vfio
vfio_iommu_type1
vfio_pci
```

#### Update initramfs

`update-initramfs -u -k all`

IF, you are running an older proxmox kernel- like me... you may get a bunch of errors when doing this.

If so- I documented the resolutions for my errors.

If, you don't have errors, you can skip the next few sections.


##### Fixing "System booted in EFI-mode but 'grub-efi-amd64' meta-package not installed! Install 'grub-efi-amd64' to get updates."

Apparently some of the older versions of the proxmox installer included the incorrect package of `grub-pc` instead of `grub-efi-amd64`

You can run `apt-get install grub-efi-amd64` to correct this, and it will remove the old package.

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

##### Fixing "Couldn't find EFI system partition. It is recommended to mount it to /boot or /efi."

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

##### Fixing "/etc/kernel/proxmox-boot-uuids does not exist."

First- run this-

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

##### Update initramfs

After fixing all three of the above errors, it is once again time to update the initramfs.

``` bash
# Remount /boot/efi (Need to use YOUR boot partition. Don't copy mine!)
mount /dev/nvme0n1p2 /boot/efi
# And... update initramfs again
update-initramfs -u -k all
```

!!! info
    I noticed it was successfully updating the kernel... and quite a few other older versions.

    At this point, I cleaned out all of the older kernel versions.

    I added this section near the top, before starting any additional steps.

Success!

``` bash
root@kube01:~# update-initramfs -u -k all
update-initramfs: Generating /boot/initrd.img-6.8.4-2-pve
Running hook script 'zz-proxmox-boot'..
Re-executing '/etc/kernel/postinst.d/zz-proxmox-boot' in new private mount namespace..
No /etc/kernel/cmdline found - falling back to /proc/cmdline
Copying and configuring kernels on /dev/disk/by-uuid/D34B-A25D
No initrd-image /boot/initrd.img-6.5.13-5-pve found - skipping
        Copying kernel 6.8.4-2-pve
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-6.8.4-2-pve
Found initrd image: /boot/initrd.img-6.8.4-2-pve
Found linux image: /boot/vmlinuz-6.5.13-5-pve
Found initrd image: /boot/initrd.img-6.5.13-5-pve
Adding boot menu entry for UEFI Firmware Settings ...
done
```

#### Reboot, and cross your fingers

!!! info
    At this point- I also decided to update my system. 

    After, receiving another kernel update.... 
    
    I added another section near the top of this post to update the system BEFORE starting these steps.


Execute the `reboot` command, and cross your fingers...

``` bash
root@kube01:~# reboot
```

``` cmd
"ZEWINDERSSHELL>ping 10.100.4.100 -t

Pinging 10.100.4.100 with 32 bytes of data:
Reply from 10.100.4.100: bytes=32 time<1ms TTL=63
Reply from 10.100.4.100: bytes=32 time<1ms TTL=63
Reply from 10.100.4.100: bytes=32 time<1ms TTL=63
Reply from 10.100.4.100: bytes=32 time<1ms TTL=63
Request timed out.
Request timed out.
Request timed out.
Request timed out.
```

At this point, stick with it, and hope for the best. Prepare to pull out the KVM / Monitor / AMT/vPro...

``` cmd
Request timed out.
Request timed out.
Request timed out.
Request timed out.
Request timed out.
Request timed out.
Request timed out.
Reply from 10.100.4.100: bytes=32 time<1ms TTL=63
Reply from 10.100.4.100: bytes=32 time<1ms TTL=63
Reply from 10.100.4.100: bytes=32 time<1ms TTL=63
Reply from 10.100.4.100: bytes=32 time<1ms TTL=63
```

Now, breathe a very large sigh of relief

### Test 

Make sure the vfio kernel modules are loaded-

``` bash
root@kube01:~# lsmod | grep vfio
vfio_pci               16384  0
vfio_pci_core          86016  1 vfio_pci
irqbypass              12288  2 vfio_pci_core,kvm
vfio_iommu_type1       49152  0
vfio                   69632  3 vfio_pci_core,vfio_iommu_type1,vfio_pci
iommufd                98304  1 vfio
```

All good there. Check, if IOMMU was enabled.

``` bash
root@kube01:~# dmesg | grep -e DMAR -e IOMMU -e AMD-Vi
[    0.008532] ACPI: DMAR 0x0000000079719328 0000A8 (v01 INTEL  EDK2     00000002      01000013)
[    0.008563] ACPI: Reserving DMAR table memory at [mem 0x79719328-0x797193cf]
[    0.052282] DMAR: IOMMU enabled
[    0.142067] DMAR: Host address width 39
[    0.142068] DMAR: DRHD base: 0x000000fed90000 flags: 0x0
[    0.142076] DMAR: dmar0: reg_base_addr fed90000 ver 1:0 cap 1c0000c40660462 ecap 19e2ff0505e
[    0.142078] DMAR: DRHD base: 0x000000fed91000 flags: 0x1
[    0.142081] DMAR: dmar1: reg_base_addr fed91000 ver 1:0 cap d2008c40660462 ecap f050da
[    0.142083] DMAR: RMRR base: 0x0000007a1ac000 end: 0x0000007a3f5fff
[    0.142086] DMAR: RMRR base: 0x0000007d000000 end: 0x0000007f7fffff
[    0.142088] DMAR-IR: IOAPIC id 2 under DRHD base  0xfed91000 IOMMU 1
[    0.142089] DMAR-IR: HPET id 0 under DRHD base 0xfed91000
[    0.142090] DMAR-IR: Queued invalidation will be enabled to support x2apic and Intr-remapping.
[    0.144856] DMAR-IR: Enabled IRQ remapping in x2apic mode
[    0.428707] DMAR: No ATSR found
[    0.428708] DMAR: No SATC found
[    0.428710] DMAR: IOMMU feature fl1gp_support inconsistent
[    0.428711] DMAR: IOMMU feature pgsel_inv inconsistent
[    0.428712] DMAR: IOMMU feature nwfs inconsistent
[    0.428713] DMAR: IOMMU feature pasid inconsistent
[    0.428714] DMAR: IOMMU feature eafs inconsistent
[    0.428715] DMAR: IOMMU feature prs inconsistent
[    0.428715] DMAR: IOMMU feature nest inconsistent
[    0.428716] DMAR: IOMMU feature mts inconsistent
[    0.428717] DMAR: IOMMU feature sc_support inconsistent
[    0.428718] DMAR: IOMMU feature dev_iotlb_support inconsistent
[    0.428719] DMAR: dmar0: Using Queued invalidation
[    0.428722] DMAR: dmar1: Using Queued invalidation
[    0.429330] DMAR: Intel(R) Virtualization Technology for Directed I/O
root@kube01:~#
```


Finish this guide: https://pve.proxmox.com/wiki/PCI(e)_Passthrough

Also, enable SRV-IOV

https://forum.proxmox.com/threads/enabling-sr-iov-for-intel-nic-x550-t2-on-proxmox-6.56677/