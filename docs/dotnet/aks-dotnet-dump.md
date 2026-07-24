---
title: Capture a .NET Memory Dump in AKS
parent: .NET & Cloud Diagnostics
grand_parent: Guides
nav_order: 2
description: "Safely capture and retrieve a .NET process memory dump from an AKS pod."
tags: [dotnet, aks, memory-dump]
last_modified_date: 2026-07-24
---

## Capture a .NET memory dump in AKS

This procedure runs `dotnet-dump` in the same container as the target .NET
process. Use it only when the container has a shell, a writable temporary
directory, and enough available memory and ephemeral storage.

{: .warning }
> Collecting a heap or full dump can substantially increase memory and disk
> usage. A container close to its memory limit can be terminated during
> collection. The target process can also pause while the dump is written.
> Test the procedure and schedule a controlled collection window.

{: .important }
> Memory dumps can contain credentials, access tokens, personal data, request
> content, and encryption material. Store, transfer, retain, and delete the dump
> according to your organization's approved diagnostic-data process.

### Prerequisites

- `kubectl` access with permission to run `pods/exec` in the target namespace.
- The target namespace, pod, and container names.
- Enough free ephemeral storage for a file comparable to the process memory
  footprint.
- `dotnet-dump` must run as the same user as the target process or as root.
- The target process and `dotnet-dump` must use the same `TMPDIR`.
- The container security policy must permit the required `ptrace` operation.

Do not install a package manager or permanently add diagnostic tools to a
production container solely for an ad hoc collection.

### 1. Confirm the target container

List the containers in the pod:

```bash
kubectl get pod <pod> -n <namespace> -o jsonpath='{.spec.containers[*].name}'
```

Open a shell in the selected container:

```bash
kubectl exec -it <pod> -n <namespace> -c <container> -- /bin/sh
```

If the image has no shell, is read-only, or is distroless, stop here. Use a
prebuilt diagnostic image or sidecar designed for this workload. A sidecar must
share the process namespace and the diagnostic socket directory, normally
`/tmp`, with the target container.

### 2. Place the matching `dotnet-dump` binary

Inside the target container, identify its architecture:

```bash
uname -m
```

Use the matching Microsoft direct-download package. For example, for a glibc
x64 image with `curl` already installed:

```bash
cd /tmp
curl -fL https://aka.ms/dotnet-dump/linux-x64 -o dotnet-dump
chmod 700 dotnet-dump
```

Microsoft also publishes Linux Arm, Arm64, musl-x64, and musl-Arm64 packages.
Do not use the x64 binary on a different architecture or on an incompatible
musl-based image.

If outbound download is blocked, transfer an approved, integrity-verified
binary to `/tmp/dotnet-dump`. `kubectl cp` requires `tar` inside the container;
if `tar` is unavailable, use your organization's diagnostic image or artifact
transfer process instead of modifying the application image.

### 3. Identify the .NET process

List compatible .NET processes:

```bash
/tmp/dotnet-dump ps
```

Record the PID for the affected application. Use a PID rather than the process
name when more than one .NET process is present.

### 4. Collect the dump

Choose the dump type requested for the investigation:

- `Heap` captures managed heaps, threads, stacks, exceptions, and handles
  without mapped module images.
- `Full` is larger and should be used only when the additional memory is
  required.

Collect to a known writable path:

```bash
/tmp/dotnet-dump collect --process-id <pid> --type Heap --output /tmp/app-heap.dmp
```

Wait for the command to report that the dump was written successfully. If it
fails with a connection, permission, or incompatible-runtime error, do not
weaken the pod security configuration without approval. Verify the process
user, `TMPDIR`, diagnostic socket, and `ptrace` requirements first.

### 5. Copy the dump from the pod

Run this command from a second terminal:

```bash
kubectl cp <namespace>/<pod>:/tmp/app-heap.dmp ./app-heap.dmp -c <container>
```

Verify that the local file exists and has a nonzero size before deleting the
pod copy. Copy the file immediately because a pod restart removes data stored
only in the container writable layer.

### 6. Clean up

After the local copy has been verified, remove the temporary files:

```bash
kubectl exec <pod> -n <namespace> -c <container> -- rm -f /tmp/app-heap.dmp /tmp/dotnet-dump
```

Upload the dump only through an approved encrypted channel, restrict access to
the investigation team, and delete local and remote copies when the retention
period ends.

## References

- [dotnet-dump diagnostic tool](https://learn.microsoft.com/en-us/dotnet/core/diagnostics/dotnet-dump)
- [Collect diagnostics in Linux containers](https://learn.microsoft.com/en-us/dotnet/core/diagnostics/diagnostics-in-containers)
- [kubectl exec](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_exec/)
- [kubectl cp](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_cp/)
