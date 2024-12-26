---
title: Edgemax - Git Backups
date: 2024-12-26
tags:
    - Homelab
    - Networking
    - Networking/Edgemax
---

# Edgemax - Auto sync configuration to git

Many years ago, I had setup a system which would automatically sync my Edgemax's configuration to a local git repo.

It worked so good, I had completely forgotten about it. During a firmware update last year, it had stopped working.

So- I went through, fixed and updated the scripts- and I am now sharing them with you.

<!-- more -->

## Before you start

!!! danger
    Take backups!!!!!

    I am not responsible for you losing your entire configuration !

    Take a backup before you touch anything. Save it somewhere AWAY from the router.

## Prerequisites

1. Have a working git repository.
2. Edgerouter/Edgemax will need internet access to download the git package.

## Installation

The entire script is [LOCATED HERE](./assets/edgemax-install-script.sh)

