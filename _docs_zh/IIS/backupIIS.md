---
title: 备份和还原 IIS 配置
permalink: /zh/docs/IIS/backupIIS/
parent: IIS 与 Web 托管
grand_parent: 指南
nav_order: 6
description: "使用 AppCmd 创建、验证并安全还原 IIS 配置备份。"
tags: [iis, configuration, backup]
last_modified_date: 2026-08-02
---

## 备份和还原 IIS 配置

AppCmd 会备份全局 IIS 服务器配置。在更改 IIS 设置或安装会修改 IIS 配置的组件之前，请创建一个具名备份。

{: .important }
> IIS 配置备份不是完整的网站或服务器备份。它不包含网站内容、应用程序二进制文件和数据、文件系统权限、数据库或证书私钥。请单独备份这些项目。

### 创建手动 AppCmd 备份

1. 以管理员身份打开 **Command Prompt**。
2. 转到 IIS 管理目录：

   ```bat
   cd /d %windir%\System32\inetsrv
   ```

3. 使用唯一名称创建备份：

   ```bat
   appcmd add backup "BeforeChange-20260724"
   ```

   ![创建 IIS 配置备份](/assets/images/backupIIS1.png)

4. 确认备份已列出：

   ```bat
   appcmd list backup
   ```

   ![列出 IIS 配置备份](/assets/images/backupIIS2.png)

手动 AppCmd 备份存储在：

```text
%windir%\System32\inetsrv\backup\<backup-name>
```

每个备份都包含 `ApplicationHost.config` 和相关的全局 IIS 配置文件。执行计划的更改之前，请检查备份目录。

### 了解自动配置历史记录

IIS 还会维护自动配置历史快照。默认位置为：

```text
%SystemDrive%\inetpub\history\CFGHISTORY_*
```

这些快照与手动命名的 AppCmd 备份相互独立。手动备份和可用的 `CFGHISTORY_*` 快照都可能出现在 `appcmd list backup` 的输出中。

自动历史记录位置、保留数量和间隔由 IIS `configHistory` 设置控制，可能与默认值不同。

### 还原备份

{: .warning }
> 还原 AppCmd 备份会在替换全局配置时停止 IIS。请安排维护窗口，先为当前状态创建新的备份，并确认已选择正确的服务器级备份。

1. 列出可用备份：

   ```bat
   appcmd list backup
   ```

2. 还原选定的备份：

   ```bat
   appcmd restore backup "BeforeChange-20260724"
   ```

   ![还原 IIS 配置备份](/assets/images/backupIIS3.png)

3. 确认命令报告还原成功。
4. 验证预期的网站和应用程序池：

   ```bat
   appcmd list site
   appcmd list apppool
   ```

5. 测试受影响的应用程序、绑定、身份验证和日志记录配置。

如果还原未解决问题，请还原操作前立即创建的备份，而不是手动编辑多个配置文件。

## 参考

- [AppCmd.exe 入门：管理备份](https://learn.microsoft.com/en-us/iis/get-started/getting-started-with-iis/getting-started-with-appcmdexe#managing-backups)
- [在 IIS 中使用配置历史记录](https://learn.microsoft.com/en-us/iis/manage/managing-your-configuration-settings/using-configuration-history-with-iis-7-and-iis-8)
- [IIS configHistory 参考](https://learn.microsoft.com/en-us/iis/configuration/system.applicationhost/confighistory)
