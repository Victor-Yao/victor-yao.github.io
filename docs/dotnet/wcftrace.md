---
title: Collect WCF and Network Traces
parent: .NET & Cloud Diagnostics
grand_parent: Guides
nav_order: 1
description: "Collect WCF activity, message, and network traces with one .NET Framework configuration."
tags: [dotnet, wcf, tracing, networking]
last_modified_date: 2026-10-02
---

## Prepare

For WCF clients and services on **.NET Framework**, not CoreWCF.

1. Back up the client or service configuration.
2. Create `c:\logs` if it does not exist.
3. Grant the application identity **Modify** permission; for IIS, use the app pool identity.
4. Use separate output directories for client and server processes.

## Complete diagnostic configuration

This configuration collects WCF activities, message headers, malformed messages, and network traces.

{: .warning }
> Merge these diagnostic settings into the existing configuration; do not replace
> the whole file. Keep business settings and avoid duplicate sections, sources, or listeners.

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
           initializeData="c:\logs\wcf-activity.svclog"
           traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
      <add name="wcfMessages"
           type="System.Diagnostics.XmlWriterTraceListener"
           initializeData="c:\logs\wcf-messages.svclog"
           traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
      <add name="WcfNetTrace"
           type="System.Diagnostics.TextWriterTraceListener"
           initializeData="c:\logs\network.log"
           traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
    </sharedListeners>
    <trace autoflush="true" />
  </system.diagnostics>
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
</configuration>
```

| File | Contents |
| --- | --- |
| `wcf-activity.svclog` | WCF activities and errors |
| `wcf-messages.svclog` | Message headers and malformed messages |
| `network.log` | `System.Net` and `System.Net.Sockets` traces |

Limits: 500 messages, a 64 KiB message-size threshold, and 1 KiB per network data
output. Well-formed message bodies and transport-level message logging remain disabled.

## Collect

1. Save the configuration.
2. Restart the application; for IIS, recycle its app pool.
3. Reproduce once and record the local time.
4. Check that the log files were generated.

Open `.svclog` files in
[Service Trace Viewer](https://learn.microsoft.com/en-us/dotnet/framework/wcf/service-trace-viewer-tool-svctraceviewer-exe)
and locate the recorded time window.

## After collection

1. Restore the backed-up configuration.
2. Restart the application or recycle its IIS app pool to apply the configuration.
3. Delete unneeded log files.

## References

- [Configuring WCF message logging](https://learn.microsoft.com/en-us/dotnet/framework/wcf/diagnostics/configuring-message-logging)
- [Recommended settings for WCF tracing and message logging](https://learn.microsoft.com/en-us/dotnet/framework/wcf/diagnostics/tracing/recommended-settings-for-tracing-and-message-logging)
- [Configure .NET Framework network tracing](https://learn.microsoft.com/en-us/dotnet/framework/network-programming/how-to-configure-network-tracing)
- [Interpret network tracing](https://learn.microsoft.com/en-us/dotnet/framework/network-programming/interpreting-network-tracing)
