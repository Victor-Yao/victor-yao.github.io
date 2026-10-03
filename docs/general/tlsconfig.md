---
title: Collect Windows TLS Configuration
parent: Windows & Networking
grand_parent: Guides
nav_order: 8
description: "Collect Windows TLS protocol and cipher-suite configuration for troubleshooting."
tags: [windows, tls, security]
last_modified_date: 2026-10-03
last_verified_date: 2026-08-02
tested_on: Windows 11 Enterprise (build 26200)
---

## Get TLS configuration from Windows

1. Download [toolkit.zip](https://github.com/Victor-Yao/victor-yao.github.io/releases/download/v0.0.0/toolkit.zip), then unzip it.

2. Open **Command Prompt** as an administrator and go to the extracted `toolkit` folder.

3. Run `GetTlsConfig.bat`.

4. Run `dir /B reports` to check the output files. `<computer-name>` is the Windows computer name:

   ```text
   <computer-name>_ssl1.txt
   <computer-name>_ssl2.txt
   <computer-name>_ssl3.txt
   <computer-name>_ssl4.txt
   ```
