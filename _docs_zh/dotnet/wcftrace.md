---
title: 收集 WCF 与网络跟踪
permalink: /zh/docs/dotnet/wcftrace/
parent: .NET 与云诊断
grand_parent: 指南
nav_order: 1
description: "使用脚本修改并恢复配置，收集 .NET Framework 应用的 WCF 活动、消息和网络跟踪。"
tags: [dotnet, wcf, tracing, networking]
last_modified_date: 2026-11-21
---

## 准备

适用于 **.NET Framework** 的 WCF 客户端和服务，不适用于 CoreWCF。

1. 找到要跟踪的进程的配置文件：
   - IIS 托管的服务：站点或应用物理路径下的 `web.config`。
   - 自托管服务或客户端：可执行文件旁边的 `<app-name>.exe.config`。
2. 同时跟踪客户端和服务端时，每个进程使用独立的日志目录，例如 `C:\logs\client` 和 `C:\logs\server`。

开启跟踪有两种方式。优先使用脚本；只有在计算机上不允许运行脚本时，才手动修改配置。

## 用脚本开启跟踪

[Set-WcfTracing.ps1]({% link assets/Scripts/Set-WcfTracing.ps1 %}) 脚本会先备份配置文件，再把诊断设置合并进去，收集完成后还原原始文件。脚本使用已有的 `<system.serviceModel>` 节，不会产生重复的节。

1. 新建 `C:\Temp` 文件夹。右键 [Set-WcfTracing.ps1]({% link assets/Scripts/Set-WcfTracing.ps1 %})，选择**链接另存为**，保存到该文件夹。
2. 以管理员身份打开 **PowerShell**，运行以下命令。将 `<config-path>` 替换为配置文件路径：

   ```powershell
   cd C:\Temp
   powershell.exe -ExecutionPolicy Bypass -File .\Set-WcfTracing.ps1 -ConfigPath "<config-path>"
   ```

   日志默认写入 `C:\logs`。如需使用其他目录，添加 `-LogDirectory "<log-directory>"`。

3. 授予应用身份对日志目录的 **Modify** 权限。IIS 场景下，将 `<app-pool-name>` 替换为应用池名称：

   ```bat
   icacls C:\logs /grant "IIS AppPool\<app-pool-name>:(OI)(CI)M"
   ```

## 手动开启跟踪

仅在无法运行脚本时使用此方法。

1. 备份配置文件，创建 `C:\logs`，并授予应用身份对该目录的 **Modify** 权限。
2. 将以下节直接添加到 `<configuration>` 下。如果已有 `<system.diagnostics>`，整节替换。

   ```xml
   <system.diagnostics>
     <sources>
       <source name="System.ServiceModel"
               switchValue="Information, ActivityTracing"
               propagateActivity="true">
         <listeners>
           <add name="wcfActivity" />
         </listeners>
       </source>
       <source name="System.ServiceModel.MessageLogging">
         <listeners>
           <add name="wcfMessages" />
         </listeners>
       </source>
       <source name="System.Net" tracemode="protocolonly" maxdatasize="1024">
         <listeners>
           <add name="WcfNetTrace" />
         </listeners>
       </source>
       <source name="System.Net.Sockets" tracemode="protocolonly" maxdatasize="1024">
         <listeners>
           <add name="WcfNetTrace" />
         </listeners>
       </source>
     </sources>
     <switches>
       <add name="System.Net" value="Verbose" />
       <add name="System.Net.Sockets" value="Verbose" />
     </switches>
     <sharedListeners>
       <add name="wcfActivity"
            type="System.Diagnostics.XmlWriterTraceListener"
            initializeData="C:\logs\wcf-activity.svclog"
            traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
       <add name="wcfMessages"
            type="System.Diagnostics.XmlWriterTraceListener"
            initializeData="C:\logs\wcf-messages.svclog"
            traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
       <add name="WcfNetTrace"
            type="System.Diagnostics.TextWriterTraceListener"
            initializeData="C:\logs\network.log"
            traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
     </sharedListeners>
     <trace autoflush="true" />
   </system.diagnostics>
   ```

3. 将以下元素添加到**已有的** `<system.serviceModel>` 节中，不要再新建一个 `<system.serviceModel>`。如果已有 `<diagnostics>`，只添加或替换其中的 `<messageLogging>` 元素。

   ```xml
   <diagnostics>
     <messageLogging logEntireMessage="false"
                     logMalformedMessages="true"
                     logMessagesAtServiceLevel="true"
                     logMessagesAtTransportLevel="false"
                     maxMessagesToLog="500"
                     maxSizeOfMessageToLog="65536" />
   </diagnostics>
   ```

4. 保存配置文件。

## 收集

1. 重启应用；IIS 回收对应应用池。
2. 复现一次问题，记录本地时间。
3. 检查是否生成以下日志文件：

   | 文件 | 内容 |
   | --- | --- |
   | `wcf-activity.svclog` | WCF 活动和错误 |
   | `wcf-messages.svclog` | 消息标头、格式错误消息 |
   | `network.log` | `System.Net`、`System.Net.Sockets` 跟踪 |

限制：最多 500 条消息，消息大小阈值 64 KiB，每次网络数据输出最多 1 KiB。格式正确的消息正文和传输层消息日志保持关闭。

用 [Service Trace Viewer](https://learn.microsoft.com/en-us/dotnet/framework/wcf/service-trace-viewer-tool-svctraceviewer-exe) 打开 `.svclog`，定位复现时间段。

## 收集后清理
{: id="收集后清尾" }

1. 还原原始配置。如果使用了脚本，运行：

   ```powershell
   cd C:\Temp
   powershell.exe -ExecutionPolicy Bypass -File .\Set-WcfTracing.ps1 -ConfigPath "<config-path>" -Restore
   ```

   如果是手动修改的，还原你的备份。

2. 重启应用或回收 IIS 应用池。
3. 删除无用日志。

## 参考

- [配置 WCF 消息日志记录](https://learn.microsoft.com/en-us/dotnet/framework/wcf/diagnostics/configuring-message-logging)
- [WCF 跟踪和消息日志记录的建议设置](https://learn.microsoft.com/en-us/dotnet/framework/wcf/diagnostics/tracing/recommended-settings-for-tracing-and-message-logging)
- [配置 .NET Framework 网络跟踪](https://learn.microsoft.com/zh-cn/dotnet/framework/network-programming/how-to-configure-network-tracing)
- [解释网络跟踪](https://learn.microsoft.com/zh-cn/dotnet/framework/network-programming/interpreting-network-tracing)
