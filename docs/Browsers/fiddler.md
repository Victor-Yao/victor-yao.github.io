---
title: Fiddler
parent: Browsers
nav_order: 1
last_modified_date: 2026-01-01
---

## Using Fidder

### Prerequisite

1. [Download](https://www.telerik.com/download/fiddler) and install Fiddler. 

    > For mor information, see: [https://docs.telerik.com/fiddler/Configure-Fiddler/Tasks/InstallFiddler](https://docs.telerik.com/fiddler/Configure-Fiddler/Tasks/InstallFiddler)

2. Open Fiddler, go to `Tools -> Options -> HTTPS tab` and check on **Decrypt HTTPS traffic**.

    ![Decrypt HTTPS traffic](/assets/images/fiddler1.jpg)

3. Select **OK** for the Security Warning about to install FiddlerRoot.

    ![Install FiddlerRoot](/assets/images/fiddler2.jpg)

    > For mor information, see:  
    [https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/decrypthttps](https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/decrypthttps)
    [https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/trustfiddlerrootcert](https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/trustfiddlerrootcert)

### Capture a Fiddler traffic

1. Select **Remove all** and **Clear Cache** in the toor bar.

    ![Remove all](/assets/images/fiddler3.jpg)

    ![Clear Cache](/assets/images/fiddler4.jpg)

2. Select `File -> Capture Traffic` for start capturing.

    ![Capture Traffic1](/assets/images/fiddler5.jpg)

    ![Capture Traffic2](/assets/images/fiddler6.jpg)

3. **Reproduce the issue**.

4. Select `File -> Capture Traffic` again for stop capturing. Then Select `File -> Save -> all Sessions` to save traffics to disk.

    ![stop recording](/assets/images/fiddler7.jpg)

> For mor information, see:  
[https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/capturing-traffic/configurebrowsers#chrome-edge-and-brave](https://www.telerik.com/fiddler/fiddler-classic/documentation/configure-fiddler/capturing-traffic/configurebrowsers#chrome-edge-and-brave)
