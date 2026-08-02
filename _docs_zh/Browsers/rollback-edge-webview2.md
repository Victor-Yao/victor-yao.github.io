---
title: 使用 MSI 回滚 Microsoft Edge
permalink: /zh/docs/Browsers/rollback-edge-webview2/
parent: 浏览器与 WebView2
grand_parent: 指南
nav_order: 23
description: "使用企业 MSI 包临时回滚 Microsoft Edge。"
tags: [edge, rollback, msi]
last_modified_date: 2026-08-02
---

## 使用 MSI 回滚 Microsoft Edge

仅在 Microsoft Edge 中存在回归问题时，将此过程用作临时缓解措施。问题解决后，请尽快将设备恢复到当前 Stable 版本。

{: .warning }
> 较旧的浏览器版本可能包含已知安全漏洞。如果没有匹配的用户数据快照，回滚还可能导致永久性浏览器数据丢失。继续前，请启用 Microsoft Edge Sync 或备份所需的用户数据。

### 范围和先决条件

- 此过程适用于 Windows 上的 Microsoft Edge 桌面浏览器。
- 它**不**适用于共享的 Evergreen WebView2 Runtime。
- 使用管理员帐户和最新的 Microsoft Edge Update 管理模板。
- 确认所需版本和体系结构可从 [Microsoft Edge for Business 下载页面](https://www.microsoft.com/edge/business/download)获取。

### 1. 临时禁用 Edge 更新

1. 打开 **本地组策略编辑器**。
2. 转到 `Computer Configuration > Administrative Templates > Microsoft Edge
   Update > Applications > Microsoft Edge`。
3. 启用 **Update policy override**，然后选择 **Update disabled**。
4. 从提升的命令提示符运行以下命令：

   ```bat
   gpupdate /force
   ```

这会防止 Microsoft Edge Update 在手动 MSI 回滚运行期间替换目标版本。

### 2. 下载并安装目标 MSI

1. 保存用户工作并关闭所有 Microsoft Edge 窗口。
2. 下载目标 Microsoft Edge MSI。匹配已安装的渠道和体系结构。
3. 以管理员身份打开 **命令提示符**，然后运行：

   ```bat
   msiexec /i "C:\Path\To\MicrosoftEdgeEnterpriseX64.msi" /qn ALLOWDOWNGRADE=1 /L*v "%TEMP%\edge-rollback.log"
   ```

所需的回滚属性为 `ALLOWDOWNGRADE=1`。安装日志写入 `%TEMP%\edge-rollback.log`。

### 3. 验证回滚

1. 重新打开 Microsoft Edge。
2. 转到 `edge://settings/help`。
3. 确认显示的版本与目标 MSI 匹配。

如果版本未更改，请查看 `%TEMP%\edge-rollback.log`，并确认目标版本存在、MSI 体系结构正确，且 Edge **Install** 策略未被禁用。

### 4. 恢复安全更新

测试完成后，将 **Update policy override** 还原为之前的值，并再次运行 `gpupdate /force`。确认 Microsoft Edge 可以更新到当前受支持的版本。

有关集中管理的回滚，请参阅
[配置 Microsoft Edge 回滚策略]({% link _docs_zh/Browsers/rollback-version.md %})。

## WebView2 Runtime 不同

不要重复使用 Edge MSI 命令来降级共享的 Evergreen WebView2 Runtime。WebView2 由多个应用程序使用，并且具有单独的服务和兼容性要求。

在 WebView2 Runtime 149 或更高版本上，企业管理员可以使用 `MSEdgeWebView2.admx` 中的 **Configure per-application WebView2 downgrade version** 策略。该策略会为特定可执行文件选择已安装的匹配主版本。它不会安装缺失的 runtime 版本，并且在没有匹配版本时不会生效。

在受影响的应用程序已通过修复后的 runtime 验证后，删除 WebView2 降级策略。

## 参考

- [How to roll back Microsoft Edge to a previous version](https://learn.microsoft.com/en-us/deployedge/edge-learnmore-rollback)
- [Microsoft Edge WebView2 DowngradeVersion policy](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-webview-policies#downgradeversion)
