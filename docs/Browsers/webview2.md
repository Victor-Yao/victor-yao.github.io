---
title: Edge WebView2
parent: Browsers
grand_parent: Guides
nav_order: 10
last_modified_date: 2026-01-01
---

## Edge WebView2 Runtime

### Get information about WebView2 Runtime

1. Download [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip), then unzip it.

2. Open **Power Shell** as an administrator, then go to `toolkit`.

3. Run `.\GetInstalledWV2.ps1` and review the output similar with below:

   ```powershell
      ~toolkit> .\GetInstalledWV2.ps1
      ==========================================================================================
      [1] Microsoft Edge WebView2 Runtime
      Version         : 143.0.3650.96
      SystemComponent : 1
      Registry Path   : HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView
      ==========================================================================================
   ```

### Show WebView2 Runtime in the installed programs

1. Open **Registry Editor**, then go to the registry path returned by **GetInstalledWV2.ps1**.
2. Set the `SystemComponent` value to `0`.
3. Press `Win+R`, run `appwiz.cpl`, then search for `WebView2`.

   ![WebView2 shown in Programs and Features](/assets/images/webview21.png)

{: .note }
> For more information, see:
>
> - [https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/end-user-faq](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/end-user-faq)
> - [https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/browser-features?source=recommendations](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/browser-features?source=recommendations)
> - [https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution?source=recommendations&tabs=dotnetcsharp#detect-if-a-webview2-runtime-is-already-installed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution?source=recommendations&tabs=dotnetcsharp#detect-if-a-webview2-runtime-is-already-installed)
