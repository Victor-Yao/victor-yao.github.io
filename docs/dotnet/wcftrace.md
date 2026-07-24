---
title: Enable WCF Tracing
parent: .NET & Cloud Diagnostics
grand_parent: Guides
nav_order: 1
description: "Enable bounded WCF activity and message tracing for .NET Framework applications."
tags: [dotnet, wcf, tracing]
last_modified_date: 2026-07-24
---

## Enable WCF tracing

This guide applies to Windows Communication Foundation applications running on
.NET Framework. It does not apply to CoreWCF or other modern .NET service
frameworks.

Start with activity tracing. Enable message logging only when activity traces
do not contain enough information for the investigation.

{: .important }
> WCF message logging can record decrypted SOAP headers and bodies, including
> credentials, tokens, personal data, and business data. Obtain authorization,
> capture the shortest possible window, and transfer the files through an
> approved secure channel.

### Prerequisites

1. Back up the client or service configuration file before editing it.
2. Create a dedicated output directory, such as `C:\Logs`.
3. Grant the application identity **Modify** permission to that directory. For
   an IIS-hosted service, this is normally the application pool identity.
4. Use different output filenames for the client and server. Two processes
   should not write to the same trace file.

### Add activity tracing

Merge the following elements into the existing `<configuration>` element. Do
not add a second `<configuration>`, `<system.diagnostics>`, or
`<system.serviceModel>` element when one already exists.

```xml
<configuration>
  <system.diagnostics>
    <sources>
      <source name="System.ServiceModel"
              switchValue="Information, ActivityTracing"
              propagateActivity="true">
        <listeners>
          <add name="wcfActivity" />
        </listeners>
      </source>
    </sources>
    <sharedListeners>
      <add name="wcfActivity"
           type="System.Diagnostics.XmlWriterTraceListener"
           initializeData="C:\Logs\wcf-activity.svclog"
           traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
    </sharedListeners>
    <trace autoflush="true" />
  </system.diagnostics>
</configuration>
```

For a long-running production capture, use `Warning` instead of `Information,
ActivityTracing` unless the additional activity data is required.

### Add bounded message logging when required

To capture WCF messages, add the `System.ServiceModel.MessageLogging` source to
the existing `<sources>` element:

```xml
<source name="System.ServiceModel.MessageLogging">
  <listeners>
    <add name="wcfMessages" />
  </listeners>
</source>
```

Add a separate listener to the existing `<sharedListeners>` element:

```xml
<add name="wcfMessages"
     type="System.Diagnostics.XmlWriterTraceListener"
     initializeData="C:\Logs\wcf-messages.svclog"
     traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
```

WCF message logging also requires the following settings inside the existing
`<system.serviceModel>` element:

```xml
<system.serviceModel>
  <diagnostics>
    <messageLogging logEntireMessage="false"
                    logMalformedMessages="true"
                    logMessagesAtServiceLevel="true"
                    logMessagesAtTransportLevel="false"
                    maxMessagesToLog="500"
                    maxSizeOfMessageToLog="65536" />
  </diagnostics>
</system.serviceModel>
```

`logEntireMessage="false"` records message headers without the body. Change it
to `true` only when the body is required and the increased data exposure has
been approved. Increase `maxMessagesToLog` or `maxSizeOfMessageToLog` only for a
known requirement.

### Collect the trace

1. Save the configuration.
2. Restart the client or Windows service. For an IIS-hosted service, recycle
   the affected application pool.
3. Confirm that the `.svclog` files are created and increasing in size.
4. Reproduce the issue once and record the local timestamp.
5. Restore the original configuration immediately after reproduction.
6. Restart or recycle the application again to stop tracing and release the
   files.
7. Copy the trace files to the approved diagnostic-data location.

Open `.svclog` files with
[Service Trace Viewer Tool (SvcTraceViewer.exe)](https://learn.microsoft.com/en-us/dotnet/framework/wcf/service-trace-viewer-tool-svctraceviewer-exe).
Use the recorded time window and activity correlation to limit the analysis.

Delete the trace files from the application server after the required copy has
been verified and the retention period has ended.

## References

- [Configuring WCF message logging](https://learn.microsoft.com/en-us/dotnet/framework/wcf/diagnostics/configuring-message-logging)
- [Recommended settings for WCF tracing and message logging](https://learn.microsoft.com/en-us/dotnet/framework/wcf/diagnostics/tracing/recommended-settings-for-tracing-and-message-logging)
