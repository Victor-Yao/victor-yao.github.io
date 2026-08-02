---
title: Deploy Microsoft Edge Administrative Templates
parent: Browsers & WebView2
grand_parent: Guides
nav_order: 21
description: "Deploy Microsoft Edge and Edge Update ADMX/ADML templates to domain or local policy stores."
tags: [edge, group-policy, admx]
last_modified_date: 2026-08-02
---

## Deploying Microsoft Edge administrative templates

This guide describes how to download and import Microsoft Edge administrative templates (ADMX/ADML) into either an Active Directory Central Store or an individual local machine. The two deployment targets are alternatives — choose the one that matches the machines you manage.

### Environment

- **Operating system**: Windows 10 / 11, Windows Server
- **Management tool**: Group Policy Management Console (GPMC) or Local Group Policy Editor (`gpedit.msc`)
- **Download source**: [Microsoft Edge for Business](https://www.microsoft.com/en-us/edge/business/download)

### Template overview

There are two distinct administrative templates required for full management of Microsoft Edge:

- **msedge.admx**: Configures browser settings (for example, home page, extensions, security policies).
- **msedgeupdate.admx**: Manages the update behavior, update frequency, and version pinning of Microsoft Edge.

### Choose a deployment target

| Deployment target | Use when | Section |
| --- | --- | --- |
| Active Directory Central Store | The machines are domain-joined and policy is managed centrally | [Deploy to the Central Store](#deploy-central-store) |
| Individual computer (Local Store) | The machine is standalone, or you are testing before a domain-wide rollout | [Deploy to a local machine](#deploy-local-store) |

### Deploy to the Active Directory Central Store
{: #deploy-central-store }

{: .note }
> Independent section. Complete only these steps. Deploying to a local machine is an alternative, not a later step.

Deploying to the Central Store makes the templates available to all Domain Administrators across the network.

1. **Download the policy files**

   Download the package from the [Microsoft Edge for Business portal](https://www.microsoft.com/en-us/edge/business/download).

2. **Copy ADMX files**

   Copy `msedge.admx` and `msedgeupdate.admx` directly into `%systemroot%\sysvol\domain\policies\PolicyDefinitions`.

3. **Copy language files (ADML)**

   Open the `EN-US` folder (or your specific locale) within the downloaded package, then copy the `.adml` files to `%systemroot%\sysvol\domain\policies\PolicyDefinitions\EN-US`.

   {: .warning }
   > If the `PolicyDefinitions` folder doesn't exist, create it manually within the `policies` directory.

### Deploy to an individual computer (Local Store)
{: #deploy-local-store }

{: .note }
> Independent section. Complete only these steps. Deploying to the Central Store is an alternative, not an earlier step.

Follow these steps if you are managing a standalone machine or testing policies before domain-wide deployment.

1. **Locate the local policy directory**

   Open File Explorer and go to `C:\Windows\PolicyDefinitions`.

2. **Install ADMX files**

   Copy the downloaded `.admx` files into the root of the `PolicyDefinitions` folder.

3. **Install ADML files**

   Copy the corresponding `.adml` files into the language-specific subfolder `C:\Windows\PolicyDefinitions\en-US`.

4. **Verify installation**

   Run `gpedit.msc` and go to `Computer Configuration > Administrative Templates`. Confirm that the **Microsoft Edge** and **Microsoft Edge Update** categories are now visible.

   {: .tip }
   > To ensure you have the latest administrative templates for the Windows OS itself, see the [Microsoft documentation](https://learn.microsoft.com/en-us/troubleshoot/windows-client/group-policy/create-and-manage-central-store) for direct download links to ADMX files categorized by Windows version.
