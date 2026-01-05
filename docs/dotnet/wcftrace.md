---
title: Enable WCF trace
parent: dotnet
nav_order: 1
last_modified_date: 2026-01-05
---

Only apply to .Net Framework WCF. For more inforamtion, see [https://learn.microsoft.com/en-us/dotnet/framework/wcf/getting-started-tutorial](https://learn.microsoft.com/en-us/dotnet/framework/wcf/getting-started-tutorial)

## Enable WCF trace log

1. Copy and paste the following configuration into the WCF configuration file for both the WCF client and the WCF server.

2. Ensure the directory specified in the `initializeData` value exists. In this example, the directory is `c:\logs`.

```xml
<configuration>
    <system.diagnostics>
        <sources>
            <source propagateActivity="true" name="System.ServiceModel" switchValue="Verbose,ActivityTracing">
                <listeners>
                    <add type="System.Diagnostics.DefaultTraceListener" name="Default">
                        <filter type="" />
                    </add>
                    <add name="xml">
                        <filter type="" />
                    </add>
                </listeners>
            </source>
            <source name="System.ServiceModel.MessageLogging">
                <listeners>
                    <add name="xml"/>
                </listeners>
            </source>
            <source name="System.Net">
                <listeners>
                    <add name="System.Net"/>
                </listeners>
            </source>
            <source name="System.Net.HttpListener">
                <listeners>
                    <add name="System.Net"/>
                </listeners>
            </source>
            <source name="System.Net.Sockets">
                <listeners>
                    <add name="System.Net"/>
                </listeners>
            </source>
            <source name="System.Net.Cache">
                <listeners>
                    <add name="System.Net"/>
                </listeners>
            </source>
        </sources>
        <sharedListeners>
            <add initializeData="c:\logs\tracelog.svclog" type="System.Diagnostics.XmlWriterTraceListener, System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" name="xml" traceOutputOptions="LogicalOperationStack, DateTime, Timestamp, ProcessId, ThreadId, Callstack">
                <filter type="" />
            </add>
            <add name="System.Net" type="System.Diagnostics.TextWriterTraceListener" initializeData="c:\logs\SNtrace.log" traceOutputOptions="DateTime" />
        </sharedListeners>
        <trace autoflush="true" />
        <switches>
            <add name="System.Net" value="Verbose" />
            <add name="System.Net.Sockets" value="Verbose" />
            <add name="System.Net.Cache" value="Verbose" />
            <add name="System.Net.HttpListener" value="Verbose" />
        </switches>
    </system.diagnostics>
</configuration>
```
