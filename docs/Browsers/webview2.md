---
title: Edge WebView2
parent: Browsers
nav_order: 1
last_modified_date: 2026-01-01
---

## Edge WebView2 Runtime

### Get information about WebView2 Runtime

1. Download [mytools.zip](/assets/mytools.zip), then unzip it.

2. Open **Power Shell** as an administrator, then go to `mytools`.

3. Run `.\GetInstalledWV2.ps1` and review the output similar with below:

   ```powershell
      ~mytools> .\GetInstalledWV2.ps1
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

> For more information, see:  

1. [https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/end-user-faq](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/end-user-faq)

2. [https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/browser-features?source=recommendations](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/browser-features?source=recommendations)

3. [https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution?source=recommendations&tabs=dotnetcsharp#detect-if-a-webview2-runtime-is-already-installed](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/distribution?source=recommendations&tabs=dotnetcsharp#detect-if-a-webview2-runtime-is-already-installed)
