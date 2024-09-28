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
:: Set "Old" Explorer Context Menu as Default
reg add "HKEY_CURRENT_USER\SOFTWARE\CLASSES\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /f

:: Remove Explorer "Command Bar"
reg add "HKCU\Software\Classes\CLSID\{d93ed569-3b3e-4bff-8355-3c44f6a52bb5}\InprocServer32" /f /ve

:: Restart Windows Explorer. (Applies the above settings without needing a reboot)
taskkill /f /im explorer.exe
start explorer.exe

:: Empty Comment (Prevents you from having to press "enter" to execute the line to restart explorer.exe)
```

<!-- more -->

## Why?

I VERY frequently right click to click, Open Folder in VSCode, Extract with 7Zip. Etc.

The windows 11 context menu, is missing basically every option, and requires me to make one extract click.

Thats it. Thats literally the entire post. Told you that you didn't need to click on it.

## How to restore Win 11 Context Menu & Explorer Command Bar

Copy and paste this into an administrative command prompt.

``` cmd
:: Restore Win 11 Explorer Context Menu
reg.exe delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f

:: Restore Win 11 Explorer Command Bar
reg.exe delete "HKCU\Software\Classes\CLSID\{d93ed569-3b3e-4bff-8355-3c44f6a52bb5}" /f

:: Restart Windows Explorer. (Applies the above settings without needing a reboot)
taskkill /f /im explorer.exe
start explorer.exe

:: Empty Comment (Prevents you from having to press "enter" to execute the line to restart explorer.exe)
```