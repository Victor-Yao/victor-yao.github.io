---
title: 配置 Microsoft Edge 回滚策略
permalink: /zh/docs/Browsers/rollback-version/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 9
description: "配置 Microsoft Edge Update 策略，将 Edge 回滚到可用的目标版本。"
tags: [edge, group-policy, rollback]
last_modified_date: 2026-08-02
---

## 使用组策略配置 Microsoft Edge 回滚

当企业部署必须临时将 Microsoft Edge 返回到较早版本时，请使用 Microsoft Edge Update 策略。

{: .warning }
> 回滚是临时缓解措施，不是长期服务策略。较旧版本可能包含已知安全漏洞，并且在没有匹配的用户数据快照时，回滚可能导致浏览器数据丢失。部署前，请启用 Sync 或备份所需的用户数据。

### 先决条件

- 安装最新的 Microsoft Edge Update 管理模板。
- 确认确切目标版本可用且受支持。
- 在小范围设备组上测试回滚，然后再广泛部署。
- 通知用户 Microsoft Edge 必须重启。

### 配置回滚

1. 打开 **组策略管理编辑器** 或 **本地组策略编辑器**。
2. 转到 `Computer Configuration > Administrative Templates > Microsoft Edge
   Update > Applications > Microsoft Edge`。
3. 启用 **Rollback to target version**。
4. 启用 **Target version override**，然后输入确切可用版本，例如 `150.0.4078.48`。
5. 启用 **Update policy override**，然后选择以下值之一：

   - **Always allow updates**
   - **Automatic silent updates only**

   不要选择 **Update disabled**。必须允许 Microsoft Edge Update 处理基于策略的回滚。
6. 从提升的命令提示符强制刷新策略：

   ```bat
   gpupdate /force
   ```

回滚会在 Microsoft Edge Update 下次检查更新时发生。

### 验证结果

1. 更新检查完成后，关闭并重新打开 Microsoft Edge。
2. 转到 `edge://settings/help`。
3. 确认显示的版本与 **Target version override** 匹配。

如果未发生回滚，请确认版本存在、版本字符串格式正确、三个策略均已应用，并且 Microsoft Edge Update 已完成更新检查。

### 移除回滚

固定的 Stable 版本可用后：

1. 禁用 **Rollback to target version**，或将其设置为 **Not configured**。
2. 移除 **Target version override**。
3. 将 **Update policy override** 还原为组织的正常设置。
4. 运行 `gpupdate /force`。
5. 在 `edge://settings/help` 确认 Microsoft Edge 返回到当前受支持版本。

有关单设备手动回滚，请参阅
[使用 MSI 回滚 Microsoft Edge]({% link _docs_zh/Browsers/rollback-edge-webview2.md %})。

{: .note }
> 这些策略适用于 Microsoft Edge 浏览器。WebView2 具有单独的按应用程序 runtime 选择策略，不能像管理 Edge 浏览器回滚一样管理它。

## 参考

- [How to roll back Microsoft Edge to a previous version](https://learn.microsoft.com/en-us/deployedge/edge-learnmore-rollback)
- [Microsoft Edge Update policy reference](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-update-policies)
