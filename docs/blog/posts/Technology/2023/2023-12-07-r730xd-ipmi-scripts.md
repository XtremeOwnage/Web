---
title: "Dell IMPI Based Fan Control"
date: 2023-12-07
categories:
  - Technology
tags:
  - Homelab
#image: "https://static.xtremeownage.com/blog/assets/Technology/2023-01/assets/r720%20on%20wall.webP"
---

# IPMI Based Fan Control for Dell Servers

I often get asked how I handle controlling fan speeds for my r730xd. 

So- today, I am sharing the scripts used.

<!-- more -->

## Intro

I am using Python based scripts, combined with racadmin to automatically control fan speed curves.

I am NOT the original author of these scripts, and I would love to link the original author, but, cannot seem to find them. (If, you are aware of the origins, please let me know, and I will update this post.)


### Scripts

#### fan-control.py

This is the primary script, which controls the fan speed.


``` python title="fan-control.py


```

I store this in `/root/fan-control/fan-control.py`

#### max-speed.py

This script is executed when my service stops, and will set the fans to maximum speed.

``` python title="max-speed.py"

```

This gets stored in `/root/fan-control/max-speed.py`