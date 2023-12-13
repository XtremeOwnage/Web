---
title: "Proxmox - Coral TPU USB Passthrough"
date: 2023-12-01
tags:
    - Home Assistant
    - Homelab
    - NVR
---

# Proxmox - Coral TPU USB Passthrough

This is a very short guide, on passing a USB Coral TPU through to a Proxmox VM.

<!-- more -->

## Step 1. Install Coral TPU Drivers on Proxmox

By default, without the coral TPU drivers installed on proxmox, you will see this:

``` bash
root@kube04:~# lsusb
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 003: ID 1a6e:089a Global Unichip Corp.
Bus 001 Device 002: ID 046d:c31c Logitech, Inc. Keyboard K120
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

To fix this, we will follow the [official instructions here](https://coral.ai/docs/accelerator/get-started/){target=_blank}

Here are the commands.

```bash
echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" | tee /etc/apt/sources.list.d/coral-edgetpu.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

apt-get update

apt-get install libedgetpu1-std
```

After running these commands, and installing the package.. Unplug the stick, and plug it back in. 

Then, wait a few minutes.

Afterwards, you will instead see this:

```bash
root@kube04:~# lsusb
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 005: ID 18d1:9302 Google Inc.
Bus 001 Device 002: ID 046d:c31c Logitech, Inc. Keyboard K120
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

This step was needed, because the USB Device ID changes.

Take note of the ID. You will need it in the next step.

## Step 2. Pass the device to your VM.

In my case, I could not see this device listed in the GUI, so, everything was done through the CLI.

Find your VM's ID. You can use the GUI if you choose. Or, you can use bash.

```bash
root@kube04:~# qm list
      VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID
       123 rancher              running    2048              32.00 690075
       131 rke-worker-4         running    8192              64.00 16128
```

In my case, I want to pass the coral TPU through to rke-worker-4. Here is the command which will be used.

So, now, a simple command will do the rest.

```bash
qm set 131 -usb0 host=18d1:9302
```

Voila. The device is now passed into the VM.

You should now be able to see the device inside of your VM.

```bash
root@rke-worker-4:/mnt/nvr# lsusb
Bus 003 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 002 Device 002: ID 18d1:9302 Google Inc.
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 0627:0001 Adomax Technology Co., Ltd QEMU Tablet
Bus 001 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
```

!!! note
    You may need to install the drivers/software inside of your VM, in order to properly use it.

    If so, follow the same directions in step 2.