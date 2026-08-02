---
title: 在 AKS 中抓取 .NET 内存转储
permalink: /zh/docs/dotnet/aks-dotnet-dump/
parent: .NET 与云诊断
grand_parent: 指南
nav_order: 2
description: "从 AKS pod 安全抓取并取回 .NET 进程内存转储。"
tags: [dotnet, aks, memory-dump]
last_modified_date: 2026-08-02
---

## 在 AKS 中抓取 .NET 内存转储

此过程会在目标 .NET 进程所在的同一容器中运行 `dotnet-dump`。仅在容器具有 shell、可写临时目录，以及足够可用内存和临时存储时使用。

{: .warning }
> 收集堆转储或完整转储可能显著增加内存和磁盘用量。接近内存限制的容器可能在收集期间被终止。写入转储时目标进程也可能暂停。请先测试该过程，并安排受控的收集窗口。

{: .important }
> 内存转储可能包含凭据、访问令牌、个人数据、请求内容和加密材料。请按照组织批准的诊断数据流程存储、传输、保留和删除转储。

### 前提条件

- 具有 `kubectl` 访问权限，并有权在目标命名空间中运行 `pods/exec`。
- 已知目标命名空间、pod 和容器名称。
- 有足够的空闲临时存储，可容纳与进程内存占用量相当的文件。
- `dotnet-dump` 必须以目标进程相同的用户身份运行，或以 root 身份运行。
- 目标进程和 `dotnet-dump` 必须使用相同的 `TMPDIR`。
- 容器安全策略必须允许所需的 `ptrace` 操作。

不要仅为一次临时收集而在生产容器中安装包管理器或永久添加诊断工具。

### 1. 确认目标容器

列出 pod 中的容器：

```bash
kubectl get pod <pod> -n <namespace> -o jsonpath='{.spec.containers[*].name}'
```

在选定容器中打开 shell：

```bash
kubectl exec -it <pod> -n <namespace> -c <container> -- /bin/sh
```

如果映像没有 shell、为只读或是 distroless，请在此停止。使用为此工作负载设计的预构建诊断映像或 sidecar。sidecar 必须与目标容器共享进程命名空间和诊断套接字目录，通常为 `/tmp`。

### 2. 放置匹配的 `dotnet-dump` 二进制文件

在目标容器内识别其架构：

```bash
uname -m
```

使用匹配的 Microsoft 直接下载包。例如，对于已安装 `curl` 的 glibc x64 映像：

```bash
cd /tmp
curl -fL https://aka.ms/dotnet-dump/linux-x64 -o dotnet-dump
chmod 700 dotnet-dump
```

Microsoft 还发布 Linux Arm、Arm64、musl-x64 和 musl-Arm64 包。不要在不同架构或不兼容的基于 musl 的映像上使用 x64 二进制文件。

如果出站下载被阻止，请将经过批准并已验证完整性的二进制文件传输到 `/tmp/dotnet-dump`。`kubectl cp` 要求容器内有 `tar`；如果没有 `tar`，请使用组织的诊断映像或工件传输流程，而不是修改应用程序映像。

### 3. 识别 .NET 进程

列出兼容的 .NET 进程：

```bash
/tmp/dotnet-dump ps
```

记录受影响应用程序的 PID。当存在多个 .NET 进程时，请使用 PID 而不是进程名称。

### 4. 收集转储

选择调查所需的转储类型：

- `Heap` 抓取托管堆、线程、堆栈、异常和句柄，但不包含映射的模块映像。
- `Full` 更大，仅在需要额外内存信息时使用。

收集到已知可写路径：

```bash
/tmp/dotnet-dump collect --process-id <pid> --type Heap --output /tmp/app-heap.dmp
```

等待命令报告转储已成功写入。如果因连接、权限或运行时不兼容错误而失败，请不要在未经批准的情况下放宽 pod 安全配置。请先验证进程用户、`TMPDIR`、诊断套接字和 `ptrace` 要求。

### 5. 从 pod 复制转储

从第二个终端运行此命令：

```bash
kubectl cp <namespace>/<pod>:/tmp/app-heap.dmp ./app-heap.dmp -c <container>
```

删除 pod 副本之前，请验证本地文件存在且大小不为零。请立即复制文件，因为 pod 重启会删除仅存储在容器可写层中的数据。

### 6. 清理

验证本地副本后，删除临时文件：

```bash
kubectl exec <pod> -n <namespace> -c <container> -- rm -f /tmp/app-heap.dmp /tmp/dotnet-dump
```

仅通过批准的加密通道上传转储，限制调查团队访问，并在保留期结束时删除本地和远程副本。

## 参考

- [dotnet-dump 诊断工具](https://learn.microsoft.com/en-us/dotnet/core/diagnostics/dotnet-dump)
- [在 Linux 容器中收集诊断信息](https://learn.microsoft.com/en-us/dotnet/core/diagnostics/diagnostics-in-containers)
- [kubectl exec](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_exec/)
- [kubectl cp](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_cp/)
