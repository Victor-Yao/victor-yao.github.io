---
title: Edge WER
parent: Browsers
nav_order: 1
last_modified_date: 2026-01-01
---

## Using WER to capture Edge crash event

1. Download [mytools.zip](/assets/mytools.zip), then unzip it.

2. Import `mytools\msedge-wer.reg` into the registry.

    ![Import reg](/assets/images/edgewer1.png)

3. Verify values in the `msedge.exe` key that exactly same show in the screenshot:

   ```text
   HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps\msedge.exe
   ```

    ![Start recording](/assets/images/edgewer2.png)

4. Create a folder at `C:\dumps`.

5. **Reproduce the issue**.

6. Verify the dump file is generated at `C:\dumps`.
