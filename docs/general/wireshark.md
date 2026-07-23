---
title: Wireshark
parent: General
grand_parent: Guides
nav_order: 7
last_modified_date: 2025-12-29
---

## Capture a network trace with Wireshark

1. Download and install [Wireshark](https://www.wireshark.org/download.html) on both the client and the server.

   {: .note }
   > Perform the remaining steps on the client and server at the same time.

2. Run Wireshark as an administrator on both systems, select the network interface, then start capturing.

   ![Select a network interface and start capturing in Wireshark](/assets/images/wireshark1.jpg)

3. Reproduce the issue.

4. Stop capturing.

   ![Stop capturing in Wireshark](/assets/images/wireshark2.jpg)

5. Save the trace files with a meaningful name.
