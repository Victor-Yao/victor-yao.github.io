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

## Explore the site

- [Blog]({% link blog/index.md %}) — Technical deep dives, investigation notes, and lessons learned.
- [Guides]({% link guides/index.md %}) — Task-focused troubleshooting, diagnostics, and log collection procedures.
- [中文指南]({% link _docs_zh/index.md %}) — Chinese translations of every guide.

## Browse guide topics

- [Windows & Networking]({% link docs/general/index.md %}) — Windows tracing, network captures, Procmon, event logs, and system diagnostics.
- [Browsers & WebView2]({% link docs/Browsers/index.md %}) — Microsoft Edge, Chrome, WebView2, browser tracing, policies, and troubleshooting.
- [IIS & Web Hosting]({% link docs/IIS/index.md %}) — IIS logging, dumps, Failed Request Tracing, ETW, and performance analysis.
- [.NET & Cloud Diagnostics]({% link docs/dotnet/index.md %}) — .NET diagnostics for applications running locally or in cloud environments.

## Featured troubleshooting guides

- [Capture a Procmon Trace]({% link docs/general/procmon.md %})
- [Capture a HAR File in Microsoft Edge]({% link docs/Browsers/edge-har.md %})
- [Collect IIS Dumps with DebugDiag]({% link docs/IIS/iisdebugdiag.md %})
- [Capture a .NET Memory Dump in AKS]({% link docs/dotnet/aks-dotnet-dump.md %})

## What to expect

- Copy/paste-ready commands with the required execution context.
- Screenshots for procedures where the UI matters.
- Safety and sensitive-data warnings for logs, dumps, and destructive operations.
- References to official documentation when deeper product details are useful.

Learn more [about this site]({% link about.md %}) and review the [usage and data privacy guidance]({% link disclaimer.md %}) before sharing diagnostic files.
