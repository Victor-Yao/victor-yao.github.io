---
title: Collect Windows TLS Configuration
parent: Windows & Networking
grand_parent: Guides
nav_order: 8
description: "Collect Windows TLS protocol and cipher-suite configuration for troubleshooting."
tags: [windows, tls, security]
last_modified_date: 2026-08-02
last_verified_date: 2026-08-02
tested_on: Windows 11 Enterprise (build 26200)
---

## Get TLS configuration from Windows

1. Download [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip), then unzip it.

2. Open **Command Prompt** as an administrator, then go to `toolkit`.

1. Run `GetTlsConfig.bat`

2. Verify the output files are created at `reports` folder as following,

   ![Generated TLS reports folder](/assets/images/gettlsconfig1.png)
