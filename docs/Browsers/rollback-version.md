---
title: Configure Microsoft Edge Rollback Policies
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 9
description: "Configure Microsoft Edge Update policies to roll Edge back to an available target version."
tags: [edge, group-policy, rollback]
last_modified_date: 2026-07-24
---

## Configure Microsoft Edge rollback with Group Policy

Use Microsoft Edge Update policies when an enterprise deployment must
temporarily return Microsoft Edge to an earlier version.

{: .warning }
> Rollback is a temporary mitigation, not a long-term servicing strategy. Older
> versions can contain known security vulnerabilities, and rollback can cause
> browser data loss when no matching user-data snapshot exists. Enable Sync or
> back up required user data before deployment.

### Prerequisites

- Install the latest Microsoft Edge Update administrative template.
- Confirm that the exact target version is available and supported.
- Test the rollback on a limited device group before broad deployment.
- Notify users that Microsoft Edge must restart.

### Configure the rollback

1. Open **Group Policy Management Editor** or **Local Group Policy Editor**.
2. Go to `Computer Configuration > Administrative Templates > Microsoft Edge
   Update > Applications > Microsoft Edge`.
3. Enable **Rollback to target version**.
4. Enable **Target version override**, then enter the exact available version,
   such as `150.0.4078.48`.
5. Enable **Update policy override**, then select one of these values:

   - **Always allow updates**
   - **Automatic silent updates only**

   Do not select **Update disabled**. Microsoft Edge Update must be allowed to
   process the policy-based rollback.
6. Force policy refresh from an elevated Command Prompt:

   ```bat
   gpupdate /force
   ```

The rollback occurs the next time Microsoft Edge Update checks for updates.

### Verify the result

1. Close and reopen Microsoft Edge after the update check completes.
2. Go to `edge://settings/help`.
3. Confirm that the displayed version matches **Target version override**.

If rollback does not occur, confirm that the version exists, the version string
is formatted correctly, all three policies are applied, and Microsoft Edge
Update has completed an update check.

### Remove the rollback

After a fixed Stable version is available:

1. Disable or set **Rollback to target version** to **Not configured**.
2. Remove **Target version override**.
3. Restore **Update policy override** to the organization's normal setting.
4. Run `gpupdate /force`.
5. Verify at `edge://settings/help` that Microsoft Edge returns to the current
   supported release.

For a one-device manual rollback, see
[Roll Back Microsoft Edge with an MSI]({% link docs/Browsers/rollback-edge-webview2.md %}).

{: .note }
> These policies apply to the Microsoft Edge browser. WebView2 has separate
> per-application runtime selection policies and must not be managed as though
> it were an Edge browser rollback.

## References

- [How to roll back Microsoft Edge to a previous version](https://learn.microsoft.com/en-us/deployedge/edge-learnmore-rollback)
- [Microsoft Edge Update policy reference](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-update-policies)
