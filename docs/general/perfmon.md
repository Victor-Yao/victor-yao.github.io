---
title: Capture Performance Counter Logs with Perfmon
parent: Windows & Networking
grand_parent: Guides
nav_order: 12
description: "Capture size-limited Windows performance counter logs for IIS, ASP.NET, .NET Framework, and WCF troubleshooting."
tags: [windows, perfmon, performance, iis, dotnet]
last_modified_date: 2026-09-02
---

## Capture performance counter logs with Perfmon

Use `logman` to collect Windows performance counters in a binary `.blg` file. The commands below sample every second and use an 800 MB circular log, so the oldest data is overwritten when the size limit is reached.

{: .warning }
> Run all commands from **Command Prompt as Administrator**. Make sure the target drive has at least 2 GB of free space before starting the capture.

### Prepare the capture

1. Create the output directory.

   ```bat
   mkdir C:\PerfMonLogs
   ```

2. Choose the counter set that matches the affected workload:

   - For IIS-hosted ASP.NET or .NET Framework applications, use the [IIS and ASP.NET counter set](#iis-and-aspnet-counter-set).
   - For WCF services, use the [WCF counter set](#wcf-counter-set).

3. Confirm that the selected counter categories exist on the affected computer.

   ```bat
   typeperf -qx
   ```

   Counter categories depend on the installed Windows roles and .NET Framework components. If `logman` reports that a counter is invalid, remove that unavailable category from the command and run it again.

### Start and stop the capture

1. Create the data collector by running the command for the selected counter set.

2. Start data collection.

   ```bat
   logman start PerfCapture
   ```

3. Reproduce the performance issue while the collector is running. Record the reproduction start and end times, including the time zone, so the activity can be correlated with the counters.

4. Stop data collection immediately after reproducing the issue.

   ```bat
   logman stop PerfCapture
   ```

5. Collect `C:\PerfMonLogs\PerfCapture.blg`.

6. Delete the data collector definition after confirming that the log file was created.

   ```bat
   logman delete PerfCapture
   ```

{: .important }
> Deleting the data collector does not delete the `.blg` file. Do not delete or rename the log until it has been copied successfully.

### IIS and ASP.NET counter set

This set captures system resources, worker processes, IIS request queues, ASP.NET, and .NET Framework memory and networking counters.

```bat
logman create counter PerfCapture ^
  -f bincirc ^
  -max 800 ^
  -si 00:00:01 ^
  -o C:\PerfMonLogs\PerfCapture.blg ^
  -c "\Memory\*" ^
     "\Process(*)\*" ^
     "\Thread(*)\*" ^
     "\Processor(*)\*" ^
     "\ASP.NET v4.0.30319\*" ^
     "\ASP.NET Apps v4.0.30319(*)\*" ^
     "\ASP.NET v2.0.50727\*" ^
     "\ASP.NET Apps v2.0.50727(*)\*" ^
     "\ASP.NET Applications(*)\*" ^
     "\ASP.NET\*" ^
     "\.NET CLR Memory(*)\*" ^
     "\.NET CLR Networking\*" ^
     "\APP_POOL_WAS(*)\*" ^
     "\HTTP Service\*" ^
     "\HTTP Service Request Queues(*)\*" ^
     "\W3SVC_W3WP(*)\*" ^
     "\WAS_W3WP(*)\*"
```

{: .note }
> ASP.NET Core does not expose the classic ASP.NET and .NET CLR counter categories shown above. For an ASP.NET Core process, retain the system, process, processor, memory, HTTP Service, and IIS counters that are available.

### WCF counter set

This set adds WCF endpoint, operation, and service counters to the system and .NET Framework counters.

```bat
logman create counter PerfCapture ^
  -f bincirc ^
  -max 800 ^
  -si 00:00:01 ^
  -o C:\PerfMonLogs\PerfCapture.blg ^
  -c "\Memory\*" ^
     "\Process(*)\*" ^
     "\Thread(*)\*" ^
     "\Processor(*)\*" ^
     "\.NET CLR Networking\*" ^
     "\.NET CLR Networking 4.0.0.0\*" ^
     "\.NET CLR Memory(*)\*" ^
     "\HTTP Service\*" ^
     "\HTTP Service Request Queues(*)\*" ^
     "\ServiceModelEndpoint 3.0.0.0(*)\*" ^
     "\ServiceModelEndpoint 4.0.0.0(*)\*" ^
     "\ServiceModelOperation 3.0.0.0(*)\*" ^
     "\ServiceModelOperation 4.0.0.0(*)\*" ^
     "\ServiceModelService 3.0.0.0(*)\*" ^
     "\ServiceModelService 4.0.0.0(*)\*" ^
     "\Web Service(*)\*"
```

WCF performance counters may be disabled by application configuration. If the ServiceModel categories are missing, confirm that WCF performance counters are enabled for the service before collecting another log.

### Verify the collector state

Use the following command to query the named collector:

```bat
logman query PerfCapture
```

To list all active collectors, run:

```bat
logman query -ets
```

If a collector named `PerfCapture` already exists, stop it:

```bat
logman stop PerfCapture
```

Then delete the old definition before creating a new collector:

```bat
logman delete PerfCapture
```
