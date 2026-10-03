---
title: 在 AKS 中抓取 .NET 内存转储
permalink: /zh/docs/dotnet/aks-dotnet-dump/
parent: .NET 与云诊断
grand_parent: 指南
nav_order: 2
description: "从 AKS pod 安全抓取并取回 .NET 进程内存转储。"
tags: [dotnet, aks, memory-dump]
last_modified_date: 2026-10-03
---

## 在 AKS 中抓取 .NET 内存转储

在目标应用所在的容器中运行 `dotnet-dump`。

运行命令前，将 `<namespace>`、`<pod>`、`<container>` 和 `<pid>` 替换为目标值。

{: .warning }
> 采集可能暂停进程、占用大量磁盘；超出内存限制可导致容器终止。先测试，再安排受控采集窗口。

{: .important }
> 转储可能包含凭据、令牌、个人数据和加密材料，按批准的诊断数据流程和保留策略处理。

### 前提条件

- `kubectl` 的 `pods/exec` 权限，以及命名空间、pod 和容器名称。
- shell、可写临时目录、足够内存，以及可容纳进程内存大小的临时存储。
- 与目标应用相同的进程用户（或 root）和 `TMPDIR`。
- 容器安全策略允许 `ptrace`。

不要为本次采集安装包管理器或永久修改生产映像。

### 1. 进入目标容器

列出容器：

```bash
kubectl get pod <pod> -n <namespace> -o jsonpath='{.spec.containers[*].name}'
```

进入选定容器：

```bash
kubectl exec -it <pod> -n <namespace> -c <container> -- /bin/sh
```

无 shell、只读或 distroless 映像，使用预构建诊断映像或 sidecar。sidecar 须共享进程命名空间和诊断套接字目录，通常为 `/tmp`。

### 2. 准备 dotnet-dump

查看容器架构：

```bash
uname -m
```

匹配架构和 libc（`glibc` 或 `musl`）。以下适用于已有 `curl` 的 glibc x64 映像：

```bash
cd /tmp
curl -fL https://aka.ms/dotnet-dump/linux-x64 -o dotnet-dump
chmod 700 dotnet-dump
```

无法下载时，将已批准且验证完整性的文件传入 `/tmp/dotnet-dump`。`kubectl cp` 要求容器中有 `tar`；否则使用批准的诊断映像或工件传输流程。

### 3. 查找 .NET 进程

列出进程：

```bash
/tmp/dotnet-dump ps
```

使用目标应用的 PID。

### 4. 收集转储

- `Heap`：托管堆、线程、堆栈、异常和句柄，不含映射的模块映像。
- `Full`：文件更大，仅在需要额外内存信息时使用。

```bash
/tmp/dotnet-dump collect --process-id <pid> --type Heap --output /tmp/app-heap.dmp
```

等待采集成功。失败时检查用户、`TMPDIR`、诊断套接字、`ptrace` 和运行时兼容性；未经批准，不要放宽安全配置。

### 5. 复制转储

在第二个终端执行：

```bash
kubectl cp <namespace>/<pod>:/tmp/app-heap.dmp ./app-heap.dmp -c <container>
```

及时复制，pod 重启会丢失可写层文件。删除 pod 副本前，确认本地文件存在且非空。

### 6. 清理

验证本地副本后，删除临时文件：

```bash
kubectl exec <pod> -n <namespace> -c <container> -- rm -f /tmp/app-heap.dmp /tmp/dotnet-dump
```

通过批准的加密通道传输，仅供调查团队访问；保留期结束后删除各处副本。

## 参考

- [dotnet-dump 诊断工具](https://learn.microsoft.com/en-us/dotnet/core/diagnostics/dotnet-dump)
- [在 Linux 容器中收集诊断信息](https://learn.microsoft.com/en-us/dotnet/core/diagnostics/diagnostics-in-containers)
- [kubectl exec](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_exec/)
- [kubectl cp](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_cp/)
