---
title: 捕获 Microsoft Edge NetExport 日志
permalink: /zh/docs/Browsers/edge-netexport/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 4
description: "使用 Microsoft Edge net-export 捕获 Chromium 网络事件。"
tags: [edge, networking, net-export]
last_modified_date: 2026-08-02
---

## 选择捕获方法

| 捕获方法 | 使用场景 | 章节 |
| --- | --- | --- |
| 浏览器内捕获 | 问题可在 Edge 已运行后重现 | [捕获 net-export](#capture-in-browser) |
| 命令行捕获 | 问题发生在启动期间，早于你打开 `edge://net-export` 的时机 | [为启动页捕获 net-export](#capture-startup) |

## 捕获 net-export
{: #capture-in-browser }

{: .note }
> 独立章节。只完成这些步骤。启动页章节是替代方案，不是后续步骤。

1. 打开 Edge 并转到 `edge://net-export`。

    {: .tip }
    > 可选：关闭除一个以外的所有浏览器标签页。

2. 选择 **Start Logging to Disk**。

    ![net-export](/assets/images/netexport.png)

3. 选择用于保存流量日志的文件名和位置。

4. 打开新标签页并**重现问题**。

    {: .warning }
    > 不要关闭 `edge://net-export` 标签页。

5. 重现问题后，选择 **Stop Logging**。

## 为启动页捕获 net-export
{: #capture-startup }

{: .note }
> 独立章节。只完成这些步骤。浏览器内捕获章节是替代方案，不是前置步骤。

1. 选择你的场景，
	
    1. 使用默认启动页打开，
        `msedge.exe --log-net-log=%USERPROFILE%\Desktop\ReproNetlog.json --net-log-capture-mode=Everything`
		
    2. 使用目标启动页打开，
        `msedge.exe --log-net-log=%USERPROFILE%\Desktop\ReproNetlog.json --net-log-capture-mode=Everything "https://www.bing.com"`
		
    3. 使用 InPrivate 模式打开，
        `msedge.exe --log-net-log=%USERPROFILE%\Desktop\ReproNetlog.json --net-log-capture-mode=Everything --inprivate`
		*提示，--incognito，\#Chrome Inprivate mode。*
		
1. 按 `Win+R` 打开运行，复制并粘贴你的选择以启动 Edge。  
	
    ![netexport1](/assets/images/netexport1.png)
	
2. 问题重现后，验证 **ReproNetlog.json** 已在 Desktop 生成。

有关详细信息，请参阅：
- [https://www.chromium.org/for-testers/providing-network-details/](https://www.chromium.org/for-testers/providing-network-details/)
- [https://textslashplain.com/2020/01/17/capture-network-logs-from-edge-and-chrome/](https://textslashplain.com/2020/01/17/capture-network-logs-from-edge-and-chrome/)
