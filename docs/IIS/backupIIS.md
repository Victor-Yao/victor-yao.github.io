---
title: Backup IIS
parent: IIS
nav_order: 1
last_modified_date: 2026-01-01
---


## Backup and restore IIS configurations

1. Open **Command Prompt** as an administrator, then go to `%windir%\System32\inetsrv\`.

2. Create a backup.

    ```bat
    appcmd add backup mybackup
    ```

    ![Create Backup](/assets/images/backupIIS1.png)

3. List existed backups.

    ```bat
    appcmd list backup
    ```

   ![List backups](/assets/images/backupIIS2.png)

    >Note: Backups that start with `CFGHISTORY_` are created automatically by IIS when you make changes.

4. Restore a backup:

    ```bat
    appcmd restore backup mybackup
    ```

   ![Restore backup](/assets/images/backupIIS3.png)

5. The backup location `C:\inetpub\history`.
