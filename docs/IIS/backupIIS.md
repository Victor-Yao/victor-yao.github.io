---
title: Back Up and Restore IIS Configuration
parent: IIS & Web Hosting
grand_parent: Guides
nav_order: 6
description: "Create, verify, and safely restore IIS configuration backups with AppCmd."
tags: [iis, configuration, backup]
last_modified_date: 2026-07-24
---

## Back up and restore IIS configuration

AppCmd backs up the global IIS server configuration. Create a named backup
before changing IIS settings or installing a component that modifies the IIS
configuration.

{: .important }
> An IIS configuration backup is not a full website or server backup. It does
> not include website content, application binaries and data, file-system
> permissions, databases, or certificate private keys. Back up those items
> separately.

### Create a manual AppCmd backup

1. Open **Command Prompt** as an administrator.
2. Go to the IIS administration directory:

   ```bat
   cd /d %windir%\System32\inetsrv
   ```

3. Create a backup with a unique name:

   ```bat
   appcmd add backup "BeforeChange-20260724"
   ```

   ![Create an IIS configuration backup](/assets/images/backupIIS1.png)

4. Confirm that the backup is listed:

   ```bat
   appcmd list backup
   ```

   ![List IIS configuration backups](/assets/images/backupIIS2.png)

Manual AppCmd backups are stored in:

```text
%windir%\System32\inetsrv\backup\<backup-name>
```

Each backup contains `ApplicationHost.config` and related global IIS
configuration files. Review the backup directory before making the planned
change.

### Understand automatic configuration history

IIS also maintains automatic configuration-history snapshots. The default
location is:

```text
%SystemDrive%\inetpub\history\CFGHISTORY_*
```

These snapshots are separate from manually named AppCmd backups. Both manual
backups and available `CFGHISTORY_*` snapshots can appear in the output of
`appcmd list backup`.

The automatic history location, retention count, and interval are controlled by
the IIS `configHistory` settings and can differ from the defaults.

### Restore a backup

{: .warning }
> Restoring an AppCmd backup stops IIS while the global configuration is
> replaced. Schedule a maintenance window, create a fresh backup of the current
> state, and confirm that you selected the correct server-wide backup.

1. List the available backups:

   ```bat
   appcmd list backup
   ```

2. Restore the selected backup:

   ```bat
   appcmd restore backup "BeforeChange-20260724"
   ```

   ![Restore an IIS configuration backup](/assets/images/backupIIS3.png)

3. Confirm that the command reports a successful restore.
4. Verify the expected websites and application pools:

   ```bat
   appcmd list site
   appcmd list apppool
   ```

5. Test the affected application, bindings, authentication, and logging
   configuration.

If the restore does not resolve the issue, restore the backup created
immediately before the operation rather than manually editing multiple
configuration files.

## References

- [Getting Started with AppCmd.exe: Managing backups](https://learn.microsoft.com/en-us/iis/get-started/getting-started-with-iis/getting-started-with-appcmdexe#managing-backups)
- [Using Configuration History with IIS](https://learn.microsoft.com/en-us/iis/manage/managing-your-configuration-settings/using-configuration-history-with-iis-7-and-iis-8)
- [IIS configHistory reference](https://learn.microsoft.com/en-us/iis/configuration/system.applicationhost/confighistory)
