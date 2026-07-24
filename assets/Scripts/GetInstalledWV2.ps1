$clientId = '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'

$machinePath = if ([Environment]::Is64BitOperatingSystem) {
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\$clientId"
}
else {
    "HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\$clientId"
}

$locations = @(
    @{
        Scope = 'Per-machine'
        Path  = $machinePath
    }
    @{
        Scope = 'Per-user'
        Path  = "HKCU:\SOFTWARE\Microsoft\EdgeUpdate\Clients\$clientId"
    }
)

$runtimes = foreach ($location in $locations) {
    $item = Get-ItemProperty -Path $location.Path -ErrorAction SilentlyContinue
    if ($item.pv -and $item.pv -ne '0.0.0.0') {
        [pscustomobject]@{
            Scope        = $location.Scope
            Version      = $item.pv
            RegistryPath = $item.PSPath -replace '^Microsoft\.PowerShell\.Core\\Registry::', ''
        }
    }
}

if (-not $runtimes) {
    Write-Warning 'No installed Evergreen WebView2 Runtime was found for this machine or user.'
    return
}

$runtimes | Format-Table -AutoSize
