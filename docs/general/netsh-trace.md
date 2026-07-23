---
title: Capture a Network Trace with netsh
parent: Windows & Networking
grand_parent: Guides
nav_order: 11
description: "Capture an ETW-backed Windows network trace with netsh."
tags: [windows, networking, etw]
last_modified_date: 2026-06-10
---

## Capture a network trace with netsh trace (ETW)

{: .note }
> Open **Command Prompt** or **PowerShell** as an administrator for all of the following steps.

### Capture the trace

1. Start capturing.

   ```cmd
   netsh trace start capture=yes tracefile=C:\Temp\nettrace.etl maxsize=2048 overwrite=yes
   ```

   - `capture=yes` enables packet capture (not just ETW events).
   - `tracefile` sets the output path. Make sure the folder exists.
   - `maxsize` is the maximum file size in MB (the default is 250 MB). When reached, capturing stops.
   - `overwrite=yes` replaces an existing trace file.

2. Reproduce the issue.

3. Stop capturing, then wait for the command to finish writing the files.

   ```cmd
   netsh trace stop
   ```

4. Collect the output files from `C:\Temp`:

   - `nettrace.etl` — the network packet capture.
   - `nettrace.cab` — system and configuration details.

### Useful options

- Capture continuously in a fixed-size circular buffer so the trace keeps only the most recent data.

  ```cmd
  netsh trace start capture=yes tracefile=C:\Temp\nettrace.etl maxsize=512 filemode=circular overwrite=yes
  ```

- Filter by a specific IP address to reduce trace size.

  ```cmd
  netsh trace start capture=yes IPv4.Address=10.0.0.5 tracefile=C:\Temp\nettrace.etl overwrite=yes
  ```

- Filter by a specific protocol and port.

  ```cmd
  netsh trace start capture=yes Protocol=TCP tracefile=C:\Temp\nettrace.etl overwrite=yes
  ```

- Persist the trace across reboots to capture a boot-time or restart issue.

  ```cmd
  netsh trace start capture=yes persistent=yes tracefile=C:\Temp\nettrace.etl overwrite=yes
  ```

  {: .note }
  > Run `netsh trace stop` after the reboot to finalize the trace.