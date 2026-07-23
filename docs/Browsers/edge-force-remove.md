---
title: Clean Cache & Force Remove Edge
parent: Browsers
grand_parent: Guides
nav_order: 16
description: "Use the provided scripts to clear Edge installer state or force-remove Edge and WebView2."
tags: [edge, webview2, installation]
last_modified_date: 2026-06-07
---

## Clean the Edge installation cache and force-remove Microsoft Edge

This guide covers two related repair scenarios for Microsoft Edge:

- **Clean the installation cache** — clears leftover registry keys and the MSI
  installer cache that can block a reinstall or an upgrade, while keeping your
  Edge folders and user data in place.
- **Force-remove Edge completely** — fully uninstalls Microsoft Edge and Edge
  WebView2, including processes, registry keys, program directories, scheduled
  tasks, the MSI installer cache, and (optionally) user profiles.

{: .warning }
> These scripts delete registry keys, files, and scheduled tasks. Run them only
> when a normal uninstall or repair has failed. Both scripts require an
> **elevated (Administrator)** PowerShell session and prompt for confirmation
> before doing anything destructive. Force-removing Edge is **not supported** on
> systems where Edge is a protected OS component, and it may need to be
> reinstalled afterward.

### When to use which script

| Goal | Script | Edge folders / user data |
| --- | --- | --- |
| Fix a stuck install or upgrade | `Edge-CleanInstallationCache.ps1` | Kept |
| Remove Edge entirely | `Edge-CompleteRemove.ps1` | Deleted (profiles optional) |

## Clean the installation cache

Use this when a reinstall or update keeps failing because of stale installer
state.

1. Download [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip), then unzip it.

2. Open **PowerShell** as an administrator, then go to the `toolkit` folder.

3. Allow the script to run for the current session, then start it:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\Edge-CleanInstallationCache.ps1
   ```

4. When prompted, type `Y` and press `Enter` to confirm.

5. The script performs the following steps:

   - Stops the `msedge`, `MicrosoftEdgeUpdate`, and `msedgewebview2` processes.
   - Deletes the Edge and Edge Update registry keys under `HKLM` and `HKCU`.
   - Clears the MSI installer cache entries (products, features, upgrade codes,
     and per-user components) for Microsoft Edge.

6. Reinstall or update Microsoft Edge from the
   [official download page](https://www.microsoft.com/edge/download).

{: .note }
> This script does **not** delete the Edge program folders or your user
> profiles, so your settings and data remain intact.

## Force-remove Microsoft Edge

Use this only when you need to remove Edge completely and the standard uninstall
is unavailable or fails.

1. Download [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip), then unzip it.

2. Open **PowerShell** as an administrator, then go to the `toolkit` folder.

3. Allow the script to run for the current session, then start it:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\Edge-CompleteRemove.ps1
   ```

4. When prompted, type `Y` and press `Enter` to confirm.

5. The script performs the following steps:

   - Stops the `msedge`, `MicrosoftEdgeUpdate`, and `msedgewebview2` processes.
   - Deletes the Edge and Edge Update registry keys under `HKLM` and `HKCU`.
   - Deletes the Edge program directories:

     - `C:\Program Files (x86)\Microsoft\Edge`
     - `C:\Program Files (x86)\Microsoft\EdgeCore`
     - `C:\Program Files (x86)\Microsoft\EdgeUpdate`
     - `C:\Program Files (x86)\Microsoft\EdgeWebView`

   - Removes scheduled tasks whose name starts with `MicrosoftEdgeUpdateTask`.
   - Clears the MSI installer cache entries for Microsoft Edge.

6. Handle user profiles when prompted. The script lists every Edge profile it
   finds under `C:\Users\<user>\AppData\Local\Microsoft\Edge`, then asks what to
   delete:

   - Enter `A` to delete **all** detected profiles.
   - Enter specific numbers separated by commas (for example, `1,3`) to delete
     only those profiles.
   - Leave the prompt blank and press `Enter` to keep all profiles.

   {: .warning }
   > Deleting a profile permanently removes that user's Edge favorites, history,
   > passwords, and other local data. Back up anything you need first.

7. When the script finishes, restart the computer.

## Reinstall Edge after a force-removal

If you need Edge again after a complete removal, download and run the latest
installer from the
[official Microsoft Edge download page](https://www.microsoft.com/edge/download).
