---
title: "Git - Delete Merged Branches"
date: 2025-06-12
tags:
  - Development/Git
---

# Git - Deleting Merged Branches

I use git for source control when writing these posts. Eventually- my local editor ends up with 50 branches which have already been merged into origin/main, and I end up needing to manually go through and remove the old branches.

This, is a VERY short post, detailing how to create a git alias to automatically prune branches, which have been merged, or deleted on your remote.

If- you don't need steps on how to create the alias, then here is the command:

`!git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D`

Otherwise, keep reading.

<!-- more -->

## Solution

A simple git alias.

Step 1. Edit your .gitconfig

On windows, `invoke-item ~/.gitconfig`

On linux, `edit/nano/vi ~/.gitconfig`

Step 2. Add the alias.

``` toml
[alias]
    fprune = !git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D
```

You can change fprune to any alias you would prefer instead.

### How to use

Simple. Type `git fprune`

```
PS C:\Users\XO\source\repos\Web> git fprune
Deleted branch DIN-Mount-Closet-Part2 (was 83c7e5a).
Deleted branch Garage-Part-1 (was 8cbd240).
Deleted branch fix-broken-links (was 9b5f439).
Deleted branch hoodcat-chronicles (was a5baab7).
Deleted branch mikrotik-outbound-vpn (was 3484c85).
```

## What, does the command do??!?

First, lets break the command down into parts.

Original Command: `!git fetch -p && git branch -vv | awk '/: gone]/{print $1}' | xargs git branch -D`

Parts:
1. git fetch -p
    - Fetch from remote. -p prunes branches which no longer exist on remote.
2. git branch -vv
    - Lists branches in verbose. Verbose includes commit id, and status on remote.
3. awk '/: gone]/{print $1}'
    - This selects branches where the remote is listed as "Gone" (aka, deleted / merged / etc)
    - Then, it selects the first column, which is the branch's name.
4. xargs git branch -D
    - This, more or less does, `xargs git branch -D your-branch-name`
    - xargs takes the stdin, and passes as an argument to the command you provide.