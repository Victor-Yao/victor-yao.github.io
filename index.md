---
title: Home
layout: home
nav_order: 0
description: "Practical troubleshooting guides, technical deep dives, and lessons learned from real-world debugging."
permalink: /
---

## Practical guides and technical deep dives

I share repeatable troubleshooting procedures, diagnostic techniques, and technical notes developed while investigating real-world problems.

The goal is to explain not only which steps to run, but also what evidence they collect and when each technique is useful.

## Browse the guides

- [General diagnostics]({% link docs/general/index.md %}) — Windows tracing, network captures, Procmon, event logs, and system diagnostics.
- [Browsers]({% link docs/Browsers/index.md %}) — Microsoft Edge, Chrome, WebView2, browser tracing, policies, and troubleshooting.
- [IIS]({% link docs/IIS/index.md %}) — IIS logging, dumps, Failed Request Tracing, ETW, and performance analysis.
- [.NET]({% link docs/dotnet/index.md %}) — .NET diagnostics for applications running locally or in cloud environments.

## Featured troubleshooting guides

- [Capture a Procmon trace]({% link docs/general/procmon.md %})
- [Export a browser HAR file]({% link docs/Browsers/edge-har.md %})
- [Capture an IIS memory dump with DebugDiag]({% link docs/IIS/iisdebugdiag.md %})
- [Capture a .NET memory dump in AKS]({% link docs/dotnet/aks-dotnet-dump.md %})

## What to expect

- Copy/paste-ready commands with the required execution context.
- Screenshots for procedures where the UI matters.
- Safety and sensitive-data warnings for logs, dumps, and destructive operations.
- References to official documentation when deeper product details are useful.

Learn more [about this site]({% link about.md %}) and review the [usage and data privacy guidance]({% link disclaimer.md %}) before sharing diagnostic files.
