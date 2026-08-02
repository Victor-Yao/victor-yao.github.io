---
title: 启用 WCF 跟踪
permalink: /zh/docs/dotnet/wcftrace/
parent: .NET 与云诊断
grand_parent: 指南
nav_order: 1
description: "为 .NET Framework 应用程序启用有界的 WCF 活动和消息跟踪。"
tags: [dotnet, wcf, tracing]
last_modified_date: 2026-08-02
---

## 启用 WCF 跟踪

本指南适用于运行在 .NET Framework 上的 Windows Communication Foundation 应用程序。不适用于 CoreWCF 或其他现代 .NET 服务框架。

先从活动跟踪开始。仅当活动跟踪未包含足够调查信息时，才启用消息日志记录。

{: .important }
> WCF 消息日志记录可能记录解密后的 SOAP 标头和正文，包括凭据、令牌、个人数据和业务数据。请先获得授权，抓取尽可能短的时间窗口，并通过批准的安全通道传输文件。

### 前提条件

1. 编辑前备份客户端或服务配置文件。
2. 创建专用输出目录，例如 `C:\Logs`。
3. 向应用程序标识授予该目录的 **Modify** 权限。对于 IIS 托管的服务，这通常是应用程序池标识。
4. 为客户端和服务器使用不同的输出文件名。两个进程不应写入同一个跟踪文件。

### 添加活动跟踪

将以下元素合并到现有 `<configuration>` 元素中。当已存在 `<configuration>`、`<system.diagnostics>` 或 `<system.serviceModel>` 元素时，不要再添加第二个。

```xml
<configuration>
  <system.diagnostics>
    <sources>
      <source name="System.ServiceModel"
              switchValue="Information, ActivityTracing"
              propagateActivity="true">
        <listeners>
          <add name="wcfActivity" />
        </listeners>
      </source>
    </sources>
    <sharedListeners>
      <add name="wcfActivity"
           type="System.Diagnostics.XmlWriterTraceListener"
           initializeData="C:\Logs\wcf-activity.svclog"
           traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
    </sharedListeners>
    <trace autoflush="true" />
  </system.diagnostics>
</configuration>
```

对于长时间运行的生产抓取，除非需要额外的活动数据，否则请使用 `Warning`，而不是 `Information,
ActivityTracing`。

### 需要时添加有界消息日志记录

若要抓取 WCF 消息，请将 `System.ServiceModel.MessageLogging` 源添加到现有 `<sources>` 元素：

```xml
<source name="System.ServiceModel.MessageLogging">
  <listeners>
    <add name="wcfMessages" />
  </listeners>
</source>
```

向现有 `<sharedListeners>` 元素添加单独的侦听器：

```xml
<add name="wcfMessages"
     type="System.Diagnostics.XmlWriterTraceListener"
     initializeData="C:\Logs\wcf-messages.svclog"
     traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
```

WCF 消息日志记录还要求在现有 `<system.serviceModel>` 元素内添加以下设置：

```xml
<system.serviceModel>
  <diagnostics>
    <messageLogging logEntireMessage="false"
                    logMalformedMessages="true"
                    logMessagesAtServiceLevel="true"
                    logMessagesAtTransportLevel="false"
                    maxMessagesToLog="500"
                    maxSizeOfMessageToLog="65536" />
  </diagnostics>
</system.serviceModel>
```

`logEntireMessage="false"` 会记录消息标头但不记录正文。仅在需要正文且已批准增加的数据暴露风险时，才将其更改为 `true`。仅针对明确需求增加 `maxMessagesToLog` 或 `maxSizeOfMessageToLog`。

### 收集跟踪

1. 保存配置。
2. 重启客户端或 Windows 服务。对于 IIS 托管的服务，请回收受影响的应用程序池。
3. 确认 `.svclog` 文件已创建且大小在增长。
4. 重现一次问题，并记录本地时间戳。
5. 重现后立即还原原始配置。
6. 再次重启或回收应用程序，以停止跟踪并释放文件。
7. 将跟踪文件复制到批准的诊断数据位置。

使用 [Service Trace Viewer Tool (SvcTraceViewer.exe)](https://learn.microsoft.com/en-us/dotnet/framework/wcf/service-trace-viewer-tool-svctraceviewer-exe) 打开 `.svclog` 文件。使用记录的时间窗口和活动关联来缩小分析范围。

在验证所需副本且保留期结束后，从应用程序服务器删除跟踪文件。

## 参考

- [配置 WCF 消息日志记录](https://learn.microsoft.com/en-us/dotnet/framework/wcf/diagnostics/configuring-message-logging)
- [WCF 跟踪和消息日志记录的建议设置](https://learn.microsoft.com/en-us/dotnet/framework/wcf/diagnostics/tracing/recommended-settings-for-tracing-and-message-logging)
