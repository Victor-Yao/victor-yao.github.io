---
title: Capture a Microsoft Edge NetExport Log
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 4
description: "Capture Chromium network events with Microsoft Edge net-export."
tags: [edge, networking, net-export]
last_modified_date: 2026-08-02
---

## Choose a capture method

| Capture method | Use when | Section |
| --- | --- | --- |
| In-browser capture | The issue can be reproduced after Edge is already running | [Capture net-export](#capture-in-browser) |
| Command-line capture | The issue happens during startup, before you can open `edge://net-export` | [Capture net-export for startup page](#capture-startup) |

## Capture net-export
{: #capture-in-browser }

{: .note }
> Independent section. Complete only these steps. The startup page section is an alternative, not a later step.

1. Open Edge and go to `edge://net-export`.

    {: .tip }
    > Optional: Close all browser tabs except one.

2. Select **Start Logging to Disk**.

    ![net-export](/assets/images/netexport.png)

3. Choose a file name and location to save the traffic log.

4. Open a new tab and **reproduce the issue**.

    {: .warning }
    > Don't close the tab of `edge://net-export`.

5. After reproducing the issue, select **Stop Logging**.

## Capture net-export for startup page
{: #capture-startup }

{: .note }
> Independent section. Complete only these steps. The in-browser capture section is an alternative, not an earlier step.

1. Select your case,
	
    1. Open with default startup page, 
        `msedge.exe --log-net-log=%USERPROFILE%\Desktop\ReproNetlog.json --net-log-capture-mode=Everything`
		
    2. Open with target startup page, 
        `msedge.exe --log-net-log=%USERPROFILE%\Desktop\ReproNetlog.json --net-log-capture-mode=Everything "https://www.bing.com"`
		
    3. Open with InPrivate mode, 
        `msedge.exe --log-net-log=%USERPROFILE%\Desktop\ReproNetlog.json --net-log-capture-mode=Everything --inprivate`
		*Tips, --incognito, \#Chrome Inprivate mode.*
		
1. Press `Win+R` to open Run, copy & paste your choice to launch Edge.  
	
    ![netexport1](/assets/images/netexport1.png)
	
2. After the issue is reproduced, verify **ReproNetlog.json** is generated at Desktop.

For more information, see: 
- [https://www.chromium.org/for-testers/providing-network-details/](https://www.chromium.org/for-testers/providing-network-details/)
- [https://textslashplain.com/2020/01/17/capture-network-logs-from-edge-and-chrome/](https://textslashplain.com/2020/01/17/capture-network-logs-from-edge-and-chrome/)