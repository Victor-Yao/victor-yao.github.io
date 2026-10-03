---
title: 收集 WCF 与网络跟踪
permalink: /zh/docs/dotnet/wcftrace/
parent: .NET 与云诊断
grand_parent: 指南
nav_order: 1
description: "使用一份完整配置收集 .NET Framework 应用的 WCF 活动、消息和网络跟踪。"
tags: [dotnet, wcf, tracing, networking]
last_modified_date: 2026-10-03
---

## 准备

适用于 **.NET Framework** 的 WCF 客户端和服务，不适用于 CoreWCF。

1. 备份客户端或服务配置文件。
2. 若 `c:\logs` 不存在，先创建目录。
3. 授予应用身份 **Modify** 权限；IIS 使用应用池身份。
4. 客户端、服务端进程使用独立的输出目录。

## 完整诊断配置

以下配置收集 WCF 活动、消息标头、格式错误消息和网络跟踪。

{: .warning }
> 不要用示例覆盖整个配置文件。仅合并诊断配置，保留业务设置；同名节、source 和 listener 不要重复添加。

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
           initializeData="c:\logs\wcf-activity.svclog"
           traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
      <add name="wcfMessages"
           type="System.Diagnostics.XmlWriterTraceListener"
           initializeData="c:\logs\wcf-messages.svclog"
           traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
      <add name="WcfNetTrace"
           type="System.Diagnostics.TextWriterTraceListener"
           initializeData="c:\logs\network.log"
           traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
    </sharedListeners>
    <trace autoflush="true" />
  </system.diagnostics>
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
</configuration>
```

| 文件 | 内容 |
| --- | --- |
| `wcf-activity.svclog` | WCF 活动和错误 |
| `wcf-messages.svclog` | 消息标头、格式错误消息 |
| `network.log` | `System.Net`、`System.Net.Sockets` 跟踪 |

采集上限：500 条消息，消息大小阈值 64 KiB；网络数据每次最多输出 1 KiB。正常消息的正文和传输层消息记录仍关闭。

## 收集

1. 保存配置。
2. 重启应用；IIS 回收对应应用池。
3. 复现一次问题，记录本地时间。
4. 检查日志文件是否生成。

用 [Service Trace Viewer](https://learn.microsoft.com/en-us/dotnet/framework/wcf/service-trace-viewer-tool-svctraceviewer-exe) 打开 `.svclog`，定位复现时间段。

## 收集后清理
{: id="收集后清尾" }

1. 还原备份配置。
2. 重启应用或回收 IIS 应用池，使配置生效。
3. 删除无用日志。

## 参考

- [配置 WCF 消息日志记录](https://learn.microsoft.com/en-us/dotnet/framework/wcf/diagnostics/configuring-message-logging)
- [WCF 跟踪和消息日志记录的建议设置](https://learn.microsoft.com/en-us/dotnet/framework/wcf/diagnostics/tracing/recommended-settings-for-tracing-and-message-logging)
- [配置 .NET Framework 网络跟踪](https://learn.microsoft.com/zh-cn/dotnet/framework/network-programming/how-to-configure-network-tracing)
- [解释网络跟踪](https://learn.microsoft.com/zh-cn/dotnet/framework/network-programming/interpreting-network-tracing)
