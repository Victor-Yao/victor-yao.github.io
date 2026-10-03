---
title: Capture a .NET Memory Dump in AKS
parent: .NET & Cloud Diagnostics
grand_parent: Guides
nav_order: 2
description: "Safely capture and retrieve a .NET process memory dump from an AKS pod."
tags: [dotnet, aks, memory-dump]
last_modified_date: 2026-10-03
---

## Capture a .NET memory dump in AKS

Run `dotnet-dump` in the target application's container.

Replace `<namespace>`, `<pod>`, `<container>`, and `<pid>` with the target values before running the commands.

{: .warning }
> Collection can pause the process, use substantial disk space, or exceed the
> memory limit and terminate the container. Test first and use a controlled capture window.

{: .important }
> Dumps may contain credentials, tokens, personal data, and encryption material.
> Follow the approved diagnostic-data handling and retention policy.

### Prerequisites

- `kubectl` with `pods/exec` permission; namespace, pod, and container names.
- A shell, writable temporary directory, enough memory, and ephemeral storage
  comparable to the process memory footprint.
- The same process user (or root) and `TMPDIR` as the target application.
- Container security policy permitting `ptrace`.

Do not install package managers or permanently modify the production image for this capture.

### 1. Open the target container

List containers:

```bash
kubectl get pod <pod> -n <namespace> -o jsonpath='{.spec.containers[*].name}'
```

Open the selected container:

```bash
kubectl exec -it <pod> -n <namespace> -c <container> -- /bin/sh
```

For shell-less, read-only, or distroless images, use a prebuilt diagnostic
image or sidecar. The sidecar must share the process namespace and diagnostic
socket directory, normally `/tmp`.

### 2. Prepare dotnet-dump

Check the container architecture:

```bash
uname -m
```

Match the architecture and libc (`glibc` or `musl`). For glibc x64 with `curl`:

```bash
cd /tmp
curl -fL https://aka.ms/dotnet-dump/linux-x64 -o dotnet-dump
chmod 700 dotnet-dump
```

If downloads are blocked, transfer an approved, integrity-verified binary to
`/tmp/dotnet-dump`. `kubectl cp` requires container-side `tar`; otherwise use
the approved diagnostic image or artifact-transfer process.

### 3. Find the .NET process

List processes:

```bash
/tmp/dotnet-dump ps
```

Use the affected application's PID.

### 4. Collect the dump

- `Heap`: managed heaps, threads, stacks, exceptions, and handles; excludes mapped module images.
- `Full`: larger; use only when the additional memory is required.

```bash
/tmp/dotnet-dump collect --process-id <pid> --type Heap --output /tmp/app-heap.dmp
```

Wait for success. On failure, check the user, `TMPDIR`, diagnostic socket,
`ptrace`, and runtime compatibility. Do not relax security settings without approval.

### 5. Copy the dump

In a second terminal:

```bash
kubectl cp <namespace>/<pod>:/tmp/app-heap.dmp ./app-heap.dmp -c <container>
```

Copy promptly: pod restarts discard writable-layer files.
Verify that the local file exists and is nonempty before deleting the pod copy.

### 6. Clean up

After verifying the local copy, remove temporary files:

```bash
kubectl exec <pod> -n <namespace> -c <container> -- rm -f /tmp/app-heap.dmp /tmp/dotnet-dump
```

Transfer through an approved encrypted channel, limit access to the investigation
team, and delete copies after the retention period.

## References

- [dotnet-dump diagnostic tool](https://learn.microsoft.com/en-us/dotnet/core/diagnostics/dotnet-dump)
- [Collect diagnostics in Linux containers](https://learn.microsoft.com/en-us/dotnet/core/diagnostics/diagnostics-in-containers)
- [kubectl exec](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_exec/)
- [kubectl cp](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_cp/)
