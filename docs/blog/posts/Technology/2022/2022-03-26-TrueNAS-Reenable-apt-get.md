---
title: "TrueNAS Scale - Enable apt-get"
date: 2022-10-28
tags:
  - TrueNAS
  - Homelab
---

# TrueNAS Scale - How to re-enable apt-get

A quick guide on re-enabling the apt-get functionality.

<!-- more -->

## The Issue

So, I updated to the official release version earlier this morning…. and was working on getting my InfiniBand cards up and running…

Well, I needed the infiniband diag tools, so, I ran:

``` bash
root@truenas:~# apt-get install infiniband-diags
bash: /bin/apt-get: Permission denied
```

Oh, that is interesting.

So, I googled around, and found this: [https://www.truenas.com/community/threads/no-apt-after-update-to-release.99579/](https://www.truenas.com/community/threads/no-apt-after-update-to-release.99579/){target=_blank}

Seems… it was disabled by design, because people do dumb stuff, make their installations unsupportable…. and, then ask for support.

Well….. I want my infiniband working. So, how do we resolve this?

## The fix

!!! warning
    I am going to assume ix-systems had a very good reason for doing this. So- if you aren't sure what you are doing, don't do it. My goal is not to increase the amount of support issues ix-systems has to deal with.

    If you run, for example, `apt-get update && apt-get upgrade`, which is a very common thing to do on most linux systems, it will BREAK your TrueNAS Scale installation. Scale is provided 'As an appliance', and any modifications or changes to the underlying OS are not supported.

!!! danger
    Before you do **ANYTHING**, take a configuration backup, and store it somewhere safe... NOT on your TrueNAS instance. That way- if you do manage to break your system, reinstall the OS, and re-import your backup. Voila, you are back up and running.

Simple!

``` bash
chmod +x /bin/apt*
```

Yup, that is literally all you need to do.


Again, to restate- If you don’t know the implications of something you are doing via CLI, DON’T DO IT!

### Adding upstream debian repositories

Also, if you DO understand the implications of something, and you know to not blow up support channels as a result of your actions, you can also update `/etc/apt/sources.list` to add in the debian repos… since, the ix-repos… are much smaller... and are missing lots of common software.

`vi /etc/apt/sources.list`

``` title="/etc/apt/sources.list"
(Add the below lines, into this file.)
deb http://deb.debian.org/debian bullseye main
deb-src http://deb.debian.org/debian bullseye main
```



I removed the other repos.... since it is shipped with apt-disabled anyways.

## Update - 2024

!!! note
    I have not personally tested the below commands as I no longer use TrueNAS.

    I am copying the information over, for others who end up here.

    Full credit here goes to u/SpecialZestyclose255

From [u/SpecialZestyclose255](https://www.reddit.com/r/truenas/comments/toyrkn/comment/l246kfy/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button){target=_blank}- 

In the latest version (24.04.0), you need to remount a virtual drive before you can use chmod +x:

`mount -o remount,rw 'boot-pool/ROOT/24.04.0/usr'`

You need to make sure that `/usr/local/bin` isn't in your PATH too.

`export PATH=/usr/bin:/usr/sbin`

And then:

`chmod +x /bin/apt*`
`chmod +x /usr/bin/dpkg`


Full Commands:
``` bash
# Remount as read-write
mount -o remount,rw 'boot-pool/ROOT/24.04.0/usr'

# Add bin / sbin directories to path.
export PATH=/usr/bin:/usr/sbin

# Add executable flag to binaries, which is emoved by the TrueNAS team.
chmod +x /bin/apt*

# Re-enable the ability to execute the dpkg binary.
chmod +x /usr/bin/dpkg

```
