---
title: AKS .NET Memory Dump
parent: .NET
grand_parent: Guides
nav_order: 2
last_modified_date: 2026-06-06
---

## Capturing a .NET memory dump in AKS

This guide describes the recommended steps for capturing a .NET memory dump from a Pod running in Azure Kubernetes Service (AKS).

### 1. Enter the target Pod

```bash
kubectl exec -ti <podname> -n dev
```

### 2. Install the required tools

```bash
apt -y update
apt -y install curl cifs-utils
cd ~

curl -L https://aka.ms/dotnet-trace/linux-x64 --output dotnet-trace
curl -L https://aka.ms/dotnet-dump/linux-x64 --output dotnet-dump

chmod +x ./dotnet-trace
chmod +x ./dotnet-dump
```

{: .note }
> If you prefer the JetBrains dotMemory console, download the `JetBrains.dotMemory.Console.linux-x64` package from your internal distribution location, extract it with `tar -xzvf <package>.tar.gz`, and make the binary executable.

### 3. Generate the dump

Using the Microsoft tooling:

```bash
./dotnet-dump collect --name dotnet
```

Or using the JetBrains tooling:

```bash
./dotmemory get-snapshot dotnet
```

### 4. Copy the dump out of the Pod

Run the following in a second terminal outside the Pod:

```bash
kubectl cp <some-namespace>/<some-pod>:<Path> <Local Path>
```

### 5. Upload the dump

Upload the dump to the designated storage location (follow your internal process for the upload target URL).
