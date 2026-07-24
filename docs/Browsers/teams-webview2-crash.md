---
title: Collect Microsoft Teams WebView2 Crash Diagnostics
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 22
description: "Collect supported Teams, Windows, and existing WebView2 crash data without changing Crashpad permissions."
tags: [teams, webview2, crash]
last_modified_date: 2026-07-24
---

## Collect Microsoft Teams WebView2 crash diagnostics

Use this guide when the Microsoft Teams desktop client crashes or closes
because of a suspected WebView2 failure.

{: .warning }
> Do not deny delete permissions on the Teams Crashpad directory, add
> system-wide heap-dump environment variables, enable internal Teams engineering
> menus, or deliberately trigger `edge://crash`. These unsupported changes can
> interfere with Teams updates, normal crash handling, and other WebView2
> applications.

{: .important }
> Teams logs and memory dumps can contain tenant names, user identifiers,
> meeting and chat metadata, URLs, tokens, and in-memory content. Collect only
> the required files and use an approved secure transfer channel.

### 1. Record the incident

Before restarting Teams, record:

- The local date and time of the crash.
- The corresponding UTC time. Teams diagnostic logs use UTC.
- The action being performed when the crash occurred.
- The Teams version and whether the problem affects one or multiple users.
- Whether Teams restarted automatically or remained closed.

### 2. Collect Teams support files

Collect the files as soon as possible after the crash:

1. Select the Teams icon in the Windows system tray, then select **Collect
   support files**.
2. Alternatively, press `Ctrl + Alt + Shift + 1`.
3. Wait until the **Downloading web logs** banner disappears.
4. Open the user's **Downloads** folder.
5. Keep the generated web-log archive and compress the Microsoft Teams support
   log files before transfer.

When multiple accounts are signed in, the output can contain diagnostic data
for every signed-in account.

### 3. Export the relevant Windows events

1. Open **Event Viewer**.
2. Go to **Windows Logs > Application**.
3. Filter the log to the incident window.
4. Include application crash and Windows Error Reporting events, commonly event
   IDs `1000` and `1001`.
5. Select **Save Filtered Log File As...** and save the result as
   `Teams-crash-Application.evtx`.

Do not copy the live `Application.evtx` file directly from
`%SystemRoot%\System32\Winevt\Logs`.

### 4. Record the WebView2 Runtime version

Follow
[Inspect the Installed WebView2 Runtime]({% link docs/Browsers/webview2.md %})
and record the installed Evergreen Runtime version without changing any
registry values.

### 5. Copy an existing Crashpad dump when available

For the current Teams package, existing Crashpad reports can appear under:

```text
%LocalAppData%\Packages\MSTeams_8wekyb3d8bbwe\LocalCache\Microsoft\MSTeams\EBWebView\Crashpad\reports
```

The path can change between Teams versions. If the directory exists and already
contains a dump from the incident time, copy the file to the diagnostic package
before restarting or updating Teams.

{: .warning }
> Do not change the directory owner or access control list and do not add a
> **Deny** entry for `Everyone`. If no dump exists, continue with the Teams and
> event logs rather than forcing a test crash.

### 6. Escalate dump collection when required

If Microsoft Support requires a full dump that Teams did not retain, use the
current, support-provided collection procedure for the affected Teams and
WebView2 versions. The instructions must identify the exact process, dump
trigger, output directory, dump limit, and cleanup steps.

Do not leave a persistent system-wide dump configuration enabled after the
collection.

### 7. Package and clean up

1. Include the incident time, Teams version, WebView2 version, Teams support
   files, filtered Application event log, and any existing matching dump.
2. Transfer the package through the approved support channel.
3. Delete temporary local copies when the required retention period ends.

This procedure does not change Teams configuration, Crashpad permissions, or
system-wide dump settings, so no system rollback is required.

## References

- [Collect Teams client diagnostic logs for Microsoft support](https://learn.microsoft.com/en-us/microsoftteams/log-files)
- [WebView2 end-user FAQ](https://learn.microsoft.com/en-us/microsoft-edge/webview2/concepts/end-user-faq)
