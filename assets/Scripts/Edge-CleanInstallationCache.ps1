function Write-Highlighted {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Remove-Reg {
    param([string]$Path)
    if (Test-Path $Path) {
        Remove-Item -Path $Path -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host "Deleted registry key: $Path" -ForegroundColor Green
    }
}

function RemoveUpgradeCodeKey {
    param(
        [string]$upgradeCodesPath,
        [string]$keyName
    )
    $upgradeCodeToDelete = Get-ChildItem -Path $upgradeCodesPath -ErrorAction SilentlyContinue | Where-Object { $_.Property.Contains($keyName) }
    if ($upgradeCodeToDelete) {
        $upgradeCodeToDelete = "$upgradeCodesPath\$(Split-Path -Leaf $upgradeCodeToDelete.Name)"
        Remove-Reg -Path $upgradeCodeToDelete
    }
}

function CleanInstallerKeys {
    param(
        [string]$rootPath
    )
    $productKeyToDelete = Get-ChildItem -Path "$rootPath\Products" -ErrorAction SilentlyContinue | Where-Object { $_.GetValue('ProductName') -eq 'Microsoft Edge' }
    if ($productKeyToDelete) {
        $name = Split-Path -Leaf $productKeyToDelete.Name
        $featurePath = "$rootPath\Features\$name"
        Remove-Reg -Path $featurePath
        $productPath = "$rootPath\Products\$name"
        Remove-Reg -Path $productPath
        RemoveUpgradeCodeKey "$rootPath\UpgradeCodes" $name
        RemoveUpgradeCodeKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes" $name
        $sysComponentPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components\$name"
        Remove-Reg -Path $sysComponentPath
        $sysProductPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$name"
        Remove-Reg -Path $sysProductPath
    }
}

# Step 1: Confirm user's intention
Write-Highlighted "This script will uninstall Microsoft Edge and Edge WebView2 from your system. Do you understand the consequences of running this script? [Y/N]"
$confirmation = Read-Host
if ($confirmation -ne 'Y') {
    Write-Host "Script execution cancelled." -ForegroundColor Red
    return
}

# Step 2: Killing the processes
Write-Highlighted "Attempting to close related processes..."
Stop-Process -Name msedge, MicrosoftEdgeUpdate, msedgewebview2 -Force -ErrorAction SilentlyContinue

# Step 3: Deleting registry keys
Write-Highlighted "Deleting associated registry keys..."
$registryPaths = @(
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate",
    "HKLM:\SOFTWARE\Microsoft\Edge",
    "HKLM:\SOFTWARE\Microsoft\EdgeUpdate",
    "HKCU:\SOFTWARE\Microsoft\Edge",
    "HKCU:\SOFTWARE\Microsoft\EdgeUpdate",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge"
)

foreach ($path in $registryPaths) {
    Remove-Reg $path
}

# Step 3: Clearing MSI Installer Cache
Write-Highlighted "Clearing MSI Installer Cache..."
CleanInstallerKeys "Registry::HKEY_CLASSES_ROOT\Installer"
CleanInstallerKeys "HKLM:\SOFTWARE\Classes\Installer"

# Script End
Write-Highlighted "Script execution completed. Microsoft Edge and Edge WebView2 have been removed from your system."