<#
.SYNOPSIS
    Exports registry-backed Microsoft Edge or Google Chrome policies to .reg files.

.DESCRIPTION
    Checks each policy key before exporting and prints one status line per key.
    "Not configured" means that policy family or hive is not present, which is
    normal on most machines; no file is created for it.

.PARAMETER Browser
    Edge (default) or Chrome.

.PARAMETER OutputPath
    Output folder. Default: browser-policy-registry on the current user's desktop.

.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File .\Export-BrowserPolicyRegistry.ps1 -Browser Edge

.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File .\Export-BrowserPolicyRegistry.ps1 -Browser Chrome
#>
[CmdletBinding()]
param(
    [ValidateSet('Edge', 'Chrome')]
    [string]$Browser = 'Edge',
    [string]$OutputPath = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'browser-policy-registry')
)

$policyKeys = if ($Browser -eq 'Edge') {
    [ordered]@{
        # Microsoft Edge browser policies
        'HKLM\SOFTWARE\Policies\Microsoft\Edge'          = 'edge-hklm.reg'
        'HKCU\SOFTWARE\Policies\Microsoft\Edge'          = 'edge-hkcu.reg'
        # Microsoft Edge WebView2 policies
        'HKLM\SOFTWARE\Policies\Microsoft\Edge\WebView2' = 'edge-webview2-hklm.reg'
        'HKCU\SOFTWARE\Policies\Microsoft\Edge\WebView2' = 'edge-webview2-hkcu.reg'
        # Microsoft Edge and WebView2 Runtime update policies
        'HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate'    = 'edge-update-hklm.reg'
    }
}
else {
    [ordered]@{
        # Google Chrome browser policies
        'HKLM\SOFTWARE\Policies\Google\Chrome' = 'chrome-hklm.reg'
        'HKCU\SOFTWARE\Policies\Google\Chrome' = 'chrome-hkcu.reg'
        # Google Update policies
        'HKLM\SOFTWARE\Policies\Google\Update' = 'chrome-update-hklm.reg'
    }
}

New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

foreach ($key in $policyKeys.Keys) {
    if (-not (Test-Path -LiteralPath "Registry::$key")) {
        Write-Host "Not configured : $key"
        continue
    }

    $file = Join-Path $OutputPath $policyKeys[$key]
    $output = reg.exe export $key $file /y 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Exported       : $key"
    }
    else {
        Write-Host "Export failed  : $key -- $output"
    }
}

Write-Host "Output folder  : $OutputPath"
