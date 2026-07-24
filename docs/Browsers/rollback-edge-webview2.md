---
title: Roll Back Microsoft Edge with an MSI
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 23
description: "Temporarily roll back Microsoft Edge with an enterprise MSI package."
tags: [edge, rollback, msi]
last_modified_date: 2026-07-24
---

## Roll back Microsoft Edge with an MSI

Use this procedure only as a temporary mitigation for a regression in Microsoft
Edge. Return the device to the current Stable release as soon as the issue is
resolved.

{: .warning }
> An older browser version can contain known security vulnerabilities. A
> rollback can also cause permanent browser data loss when no matching user-data
> snapshot is available. Enable Microsoft Edge Sync or back up required user
> data before continuing.

### Scope and prerequisites

- This procedure applies to the Microsoft Edge desktop browser on Windows.
- It does **not** apply to the shared Evergreen WebView2 Runtime.
- Use an administrator account and the latest Microsoft Edge Update
  administrative template.
- Confirm that the required version and architecture are available from the
  [Microsoft Edge for Business download page](https://www.microsoft.com/edge/business/download).

### 1. Temporarily disable Edge updates

1. Open **Local Group Policy Editor**.
2. Go to `Computer Configuration > Administrative Templates > Microsoft Edge
   Update > Applications > Microsoft Edge`.
3. Enable **Update policy override**, then select **Update disabled**.
4. Run the following command from an elevated Command Prompt:

   ```bat
   gpupdate /force
   ```

This prevents Microsoft Edge Update from replacing the target version while the
manual MSI rollback is running.

### 2. Download and install the target MSI

1. Save user work and close all Microsoft Edge windows.
2. Download the target Microsoft Edge MSI. Match the installed channel and
   architecture.
3. Open **Command Prompt** as an administrator, then run:

   ```bat
   msiexec /i "C:\Path\To\MicrosoftEdgeEnterpriseX64.msi" /qn ALLOWDOWNGRADE=1 /L*v "%TEMP%\edge-rollback.log"
   ```

The required rollback property is `ALLOWDOWNGRADE=1`. The installation log is
written to `%TEMP%\edge-rollback.log`.

### 3. Verify the rollback

1. Reopen Microsoft Edge.
2. Go to `edge://settings/help`.
3. Confirm that the displayed version matches the target MSI.

If the version did not change, review `%TEMP%\edge-rollback.log` and confirm
that the target version exists, the MSI architecture is correct, and the Edge
**Install** policy is not disabled.

### 4. Resume security updates

After testing is complete, restore **Update policy override** to its previous
value and run `gpupdate /force` again. Verify that Microsoft Edge can update to
the current supported release.

For centrally managed rollback, see
[Configure Microsoft Edge Rollback Policies]({% link docs/Browsers/rollback-version.md %}).

## WebView2 Runtime is different

Do not reuse the Edge MSI command to downgrade the shared Evergreen WebView2
Runtime. WebView2 is used by multiple applications and has separate servicing
and compatibility requirements.

On WebView2 Runtime 149 or later, enterprise administrators can use the
**Configure per-application WebView2 downgrade version** policy from
`MSEdgeWebView2.admx`. The policy selects an already-installed matching major
version for a specific executable. It does not install a missing runtime
version, and it has no effect when no matching version is present.

Remove the WebView2 downgrade policy after the affected application has been
validated with a fixed runtime.

## References

- [How to roll back Microsoft Edge to a previous version](https://learn.microsoft.com/en-us/deployedge/edge-learnmore-rollback)
- [Microsoft Edge WebView2 DowngradeVersion policy](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-webview-policies#downgradeversion)
