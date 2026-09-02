---
title: 使用 Perfmon 抓取性能计数器日志
permalink: /zh/docs/general/perfmon/
parent: Windows 与网络
grand_parent: 指南
nav_order: 12
description: "抓取限制大小的 Windows 性能计数器日志，用于排查 IIS、ASP.NET、.NET Framework 和 WCF 性能问题。"
tags: [windows, perfmon, performance, iis, dotnet]
last_modified_date: 2026-09-02
---

## 使用 Perfmon 抓取性能计数器日志

使用 `logman` 将 Windows 性能计数器收集到二进制 `.blg` 文件中。以下命令每秒采样一次，并使用 800 MB 的循环日志；达到大小上限后，最早的数据会被覆盖。

{: .warning }
> 所有命令都需要在**以管理员身份运行的命令提示符**中执行。开始抓取前，请确保目标驱动器至少有 2 GB 可用空间。

### 准备抓取

1. 创建输出目录。

   ```bat
   mkdir C:\PerfMonLogs
   ```

2. 根据出现问题的工作负载选择计数器集：

   - 对于 IIS 托管的 ASP.NET 或 .NET Framework 应用，请使用 [IIS 和 ASP.NET 计数器集](#iis-和-aspnet-计数器集)。
   - 对于 WCF 服务，请使用 [WCF 计数器集](#wcf-计数器集)。

3. 确认受影响计算机上存在所选的计数器类别。

   ```bat
   typeperf -qx
   ```

   可用的计数器类别取决于已安装的 Windows 角色和 .NET Framework 组件。如果 `logman` 报告某个计数器无效，请从命令中删除不可用的类别，然后重新运行。

### 开始和停止抓取

1. 运行所选计数器集对应的命令，创建数据收集器。

2. 开始收集数据。

   ```bat
   logman start PerfCapture
   ```

3. 在收集器运行期间重现性能问题。记录重现开始和结束时间（包括时区），以便将操作与计数器数据关联起来。

4. 重现问题后立即停止数据收集。

   ```bat
   logman stop PerfCapture
   ```

5. 收集 `C:\PerfMonLogs\PerfCapture.blg`。

6. 确认日志文件已经生成后，删除数据收集器定义。

   ```bat
   logman delete PerfCapture
   ```

{: .important }
> 删除数据收集器不会删除 `.blg` 文件。在确认日志已成功复制之前，不要删除或重命名该文件。

### IIS 和 ASP.NET 计数器集

此计数器集会收集系统资源、工作进程、IIS 请求队列、ASP.NET，以及 .NET Framework 内存和网络计数器。

```bat
logman create counter PerfCapture ^
  -f bincirc ^
  -max 800 ^
  -si 00:00:01 ^
  -o C:\PerfMonLogs\PerfCapture.blg ^
  -c "\Memory\*" ^
     "\Process(*)\*" ^
     "\Thread(*)\*" ^
     "\Processor(*)\*" ^
     "\ASP.NET v4.0.30319\*" ^
     "\ASP.NET Apps v4.0.30319(*)\*" ^
     "\ASP.NET v2.0.50727\*" ^
     "\ASP.NET Apps v2.0.50727(*)\*" ^
     "\ASP.NET Applications(*)\*" ^
     "\ASP.NET\*" ^
     "\.NET CLR Memory(*)\*" ^
     "\.NET CLR Networking\*" ^
     "\APP_POOL_WAS(*)\*" ^
     "\HTTP Service\*" ^
     "\HTTP Service Request Queues(*)\*" ^
     "\W3SVC_W3WP(*)\*" ^
     "\WAS_W3WP(*)\*"
```

{: .note }
> ASP.NET Core 不会公开上面列出的经典 ASP.NET 和 .NET CLR 计数器类别。对于 ASP.NET Core 进程，请保留系统、进程、处理器、内存、HTTP Service 和 IIS 中实际可用的计数器。

### WCF 计数器集

此计数器集在系统和 .NET Framework 计数器之外，还会收集 WCF 终结点、操作和服务计数器。

```bat
logman create counter PerfCapture ^
  -f bincirc ^
  -max 800 ^
  -si 00:00:01 ^
  -o C:\PerfMonLogs\PerfCapture.blg ^
  -c "\Memory\*" ^
     "\Process(*)\*" ^
     "\Thread(*)\*" ^
     "\Processor(*)\*" ^
     "\.NET CLR Networking\*" ^
     "\.NET CLR Networking 4.0.0.0\*" ^
     "\.NET CLR Memory(*)\*" ^
     "\HTTP Service\*" ^
     "\HTTP Service Request Queues(*)\*" ^
     "\ServiceModelEndpoint 3.0.0.0(*)\*" ^
     "\ServiceModelEndpoint 4.0.0.0(*)\*" ^
     "\ServiceModelOperation 3.0.0.0(*)\*" ^
     "\ServiceModelOperation 4.0.0.0(*)\*" ^
     "\ServiceModelService 3.0.0.0(*)\*" ^
     "\ServiceModelService 4.0.0.0(*)\*" ^
     "\Web Service(*)\*"
```

WCF 性能计数器可能被应用程序配置禁用。如果找不到 ServiceModel 类别，请先确认该服务已启用 WCF 性能计数器，再重新收集日志。

### 检查收集器状态

使用以下命令查询指定的收集器：

```bat
logman query PerfCapture
```

如需列出所有正在运行的收集器，请运行：

```bat
logman query -ets
```

如果名为 `PerfCapture` 的收集器已经存在，请先停止该收集器：

```bat
logman stop PerfCapture
```

然后删除旧定义，再创建新的收集器：

```bat
logman delete PerfCapture
```
