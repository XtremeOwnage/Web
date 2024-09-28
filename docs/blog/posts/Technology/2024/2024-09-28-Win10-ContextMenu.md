---
title: "Windows 11 - Restore Context Menu"
date: 2024-09-28
tags:
  - Homelab
  - Homelab/Windows/11
---

# Windows 11 - Restore Old Context Menu

Want the old right-click context menu back?

Copy/paste the below script into an administrative command prompt. Thats it.

``` cmd
reg add "HKEY_CURRENT_USER\SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
reg add "HKEY_CURRENT_USER\SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f
reg add "HKEY_CURRENT_USER\SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /f

:: Restart Windows Explorer. (Applies the above settings without needing a reboot)
taskkill /f /im explorer.exe
start explorer.exe
```

There is nothing further to read on this post.

<!-- more -->

## Why?

I VERY frequently right click to click, Open Folder in VSCode, Extract with 7Zip. Etc.

The windows 11 context menu, is missing basically every option, and requires me to make one extract click.

Thats it. Thats literally the entire post. Told you that you didn't need to click on it.