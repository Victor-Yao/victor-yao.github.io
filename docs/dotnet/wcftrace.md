---
title: Collect WCF and Network Traces
parent: .NET & Cloud Diagnostics
grand_parent: Guides
nav_order: 1
description: "Collect WCF activity, message, and network traces for .NET Framework applications with a script that edits and restores the configuration."
tags: [dotnet, wcf, tracing, networking]
last_modified_date: 2026-11-21
---

## Prepare

For WCF clients and services on **.NET Framework**, not CoreWCF.

1. Find the configuration file of the process to trace:
   - IIS-hosted service: `web.config` in the site or application physical path.
   - Self-hosted service or client: `<app-name>.exe.config` next to the executable.
2. Use a separate log directory for each process when you trace both the client and the server, for example `C:\logs\client` and `C:\logs\server`.

There are two ways to enable tracing. Use the script unless you are not allowed to run scripts on the computer; then edit the configuration manually.

## Enable tracing with the script

The [Set-WcfTracing.ps1]({% link assets/Scripts/Set-WcfTracing.ps1 %}) script backs up the configuration file, merges the diagnostic settings into it, and restores the original file afterwards. It uses the existing `<system.serviceModel>` section, so it does not create duplicate sections.

1. Create the `C:\Temp` folder. Right-click [Set-WcfTracing.ps1]({% link assets/Scripts/Set-WcfTracing.ps1 %}), select **Save link as**, and save it in that folder.
2. Open **PowerShell** as an administrator, then run the following commands. Replace `<config-path>` with the path to the configuration file:

   ```powershell
   cd C:\Temp
   powershell.exe -ExecutionPolicy Bypass -File .\Set-WcfTracing.ps1 -ConfigPath "<config-path>"
   ```

   Logs are written to `C:\logs` by default. To use another folder, add `-LogDirectory "<log-directory>"`.

3. Grant the application identity **Modify** permission on the log directory. For IIS, replace `<app-pool-name>` with the app pool name:

   ```bat
   icacls C:\logs /grant "IIS AppPool\<app-pool-name>:(OI)(CI)M"
   ```

## Enable tracing manually

Use this method only if you cannot run the script.

1. Back up the configuration file, create `C:\logs`, and grant the application identity **Modify** permission on it.
2. Add the following section directly under `<configuration>`. If `<system.diagnostics>` already exists, replace the whole section.

   ```xml
   <system.diagnostics>
     <sources>
       <source name="System.ServiceModel"
               switchValue="Information, ActivityTracing"
               propagateActivity="true">
         <listeners>
           <add name="wcfActivity" />
         </listeners>
       </source>
       <source name="System.ServiceModel.MessageLogging">
         <listeners>
           <add name="wcfMessages" />
         </listeners>
       </source>
       <source name="System.Net" tracemode="protocolonly" maxdatasize="1024">
         <listeners>
           <add name="WcfNetTrace" />
         </listeners>
       </source>
       <source name="System.Net.Sockets" tracemode="protocolonly" maxdatasize="1024">
         <listeners>
           <add name="WcfNetTrace" />
         </listeners>
       </source>
     </sources>
     <switches>
       <add name="System.Net" value="Verbose" />
       <add name="System.Net.Sockets" value="Verbose" />
     </switches>
     <sharedListeners>
       <add name="wcfActivity"
            type="System.Diagnostics.XmlWriterTraceListener"
            initializeData="C:\logs\wcf-activity.svclog"
            traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
       <add name="wcfMessages"
            type="System.Diagnostics.XmlWriterTraceListener"
            initializeData="C:\logs\wcf-messages.svclog"
            traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
       <add name="WcfNetTrace"
            type="System.Diagnostics.TextWriterTraceListener"
            initializeData="C:\logs\network.log"
            traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
     </sharedListeners>
     <trace autoflush="true" />
   </system.diagnostics>
   ```

3. Add the following element inside the **existing** `<system.serviceModel>` section. Do not add a second `<system.serviceModel>`. If `<diagnostics>` already exists, add or replace only its `<messageLogging>` element.

   ```xml
   <diagnostics>
     <messageLogging logEntireMessage="false"
                     logMalformedMessages="true"
                     logMessagesAtServiceLevel="true"
                     logMessagesAtTransportLevel="false"
                     maxMessagesToLog="500"
                     maxSizeOfMessageToLog="65536" />
   </diagnostics>
   ```

4. Save the configuration file.

## Collect

1. Restart the application; for IIS, recycle its app pool.
2. Reproduce once and record the local time.
3. Check that the following log files were generated:

   | File | Contents |
   | --- | --- |
   | `wcf-activity.svclog` | WCF activities and errors |
   | `wcf-messages.svclog` | Message headers and malformed messages |
   | `network.log` | `System.Net` and `System.Net.Sockets` traces |

Limits: 500 messages, a 64 KiB message-size threshold, and 1 KiB per network data output. Well-formed message bodies and transport-level message logging remain disabled.

Open `.svclog` files in [Service Trace Viewer](https://learn.microsoft.com/en-us/dotnet/framework/wcf/service-trace-viewer-tool-svctraceviewer-exe) and locate the recorded time window.

## After collection

1. Restore the original configuration. If you used the script, run:

   ```powershell
   cd C:\Temp
   powershell.exe -ExecutionPolicy Bypass -File .\Set-WcfTracing.ps1 -ConfigPath "<config-path>" -Restore
   ```

   If you edited the configuration manually, restore your backup.

2. Restart the application or recycle its IIS app pool.
3. Delete unneeded log files.

## References

- [Configuring WCF message logging](https://learn.microsoft.com/en-us/dotnet/framework/wcf/diagnostics/configuring-message-logging)
- [Recommended settings for WCF tracing and message logging](https://learn.microsoft.com/en-us/dotnet/framework/wcf/diagnostics/tracing/recommended-settings-for-tracing-and-message-logging)
- [Configure .NET Framework network tracing](https://learn.microsoft.com/en-us/dotnet/framework/network-programming/how-to-configure-network-tracing)
- [Interpret network tracing](https://learn.microsoft.com/en-us/dotnet/framework/network-programming/interpreting-network-tracing)
