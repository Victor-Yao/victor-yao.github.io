---
title: 部署 Microsoft Edge 管理模板
permalink: /zh/docs/Browsers/edge-admx/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 18
description: "将 Microsoft Edge 和 Edge Update ADMX/ADML 模板部署到域或本地策略存储。"
tags: [edge, group-policy, admx]
last_modified_date: 2026-10-03
---

## 部署 Microsoft Edge 管理模板

将 Microsoft Edge 管理模板（ADMX/ADML）部署到 Active Directory 中央存储或本地计算机。部署目标**只选一种**。

### 环境

- **操作系统**：Windows 10 / 11、Windows Server
- **管理工具**：Group Policy Management Console (GPMC) 或 Local Group Policy Editor (`gpedit.msc`)
- **下载来源**：[Microsoft Edge for Business](https://www.microsoft.com/en-us/edge/business/download)

### 模板概览

要完整管理 Microsoft Edge，需要两个不同的管理模板：

- `msedge.admx`：浏览器设置，如主页、扩展和安全策略。
- `msedgeupdate.admx`：更新行为、频率和版本固定。

### 选择部署目标

| 部署目标 | 使用场景 | 章节 |
| --- | --- | --- |
| Active Directory 中央存储 | 计算机已加入域，并且策略集中管理 | [部署到中央存储](#deploy-central-store) |
| 单台计算机（本地存储） | 计算机为独立计算机，或你在全域推出前进行测试 | [部署到本地计算机](#deploy-local-store) |

### 部署到 Active Directory 中央存储
{: #deploy-central-store }

部署到中央存储后，网络中的所有域管理员都可以使用这些模板。

1. **下载策略文件**

   从 [Microsoft Edge for Business 门户](https://www.microsoft.com/en-us/edge/business/download)下载包。

2. **复制 ADMX 文件**

   将 `msedge.admx` 和 `msedgeupdate.admx` 直接复制到 `%systemroot%\sysvol\domain\policies\PolicyDefinitions`。

3. **复制语言文件（ADML）**

   打开下载包中的 `EN-US` 文件夹（或你的特定区域设置文件夹），然后将 `.adml` 文件复制到 `%systemroot%\sysvol\domain\policies\PolicyDefinitions\EN-US`。

   {: .warning }
   > 如果 `PolicyDefinitions` 文件夹不存在，请在 `policies` 目录中手动创建。

### 部署到单台计算机（本地存储）
{: #deploy-local-store }

如果你管理的是独立计算机，或在全域部署前测试策略，请按以下步骤操作。

1. **定位本地策略目录**

   打开 **File Explorer**，转到 `C:\Windows\PolicyDefinitions`。

2. **安装 ADMX 文件**

   将下载的 `.admx` 文件复制到 `PolicyDefinitions` 文件夹的根目录。

3. **安装 ADML 文件**

   将对应的 `.adml` 文件复制到特定语言子文件夹 `C:\Windows\PolicyDefinitions\en-US`。

4. **验证安装**

   运行 `gpedit.msc`，并转到 **Computer Configuration > Administrative Templates**。确认现在可以看到 **Microsoft Edge** 和 **Microsoft Edge Update** 类别。

   {: .tip }
   > 若要确保拥有 Windows OS 本身的最新管理模板，请参阅 [Microsoft 文档](https://learn.microsoft.com/en-us/troubleshoot/windows-client/group-policy/create-and-manage-central-store)，其中按 Windows 版本提供 ADMX 文件的直接下载链接。
