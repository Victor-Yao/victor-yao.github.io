<#
.SYNOPSIS
    Collects hang dumps of a Chromium-based browser (Microsoft Edge or Google Chrome)
    while the browser is NOT responding.

.DESCRIPTION
    Run this script WHILE the browser is hung. Do NOT close the browser first.

    The script:
      1. Finds the Browser process (the msedge.exe/chrome.exe without "--type=")
         and the GPU process ("--type=gpu-process").
      2. Saves a snapshot of all browser processes (PID, parent PID, command line)
         to help with later analysis.
      3. Runs ProcDump against the Browser and GPU processes AT THE SAME TIME,
         capturing several full dumps at a fixed interval.

.PARAMETER ProcDumpPath
    Full path to procdump.exe / procdump64.exe. Default: C:\Dumps\procdump64.exe

.PARAMETER OutputRoot
    Root folder for dumps. A time-stamped subfolder is created. Default: C:\Dumps

.PARAMETER Browser
    Edge (default) or Chrome.

.PARAMETER DumpCount
    Number of dumps per process. Default: 3

.PARAMETER IntervalSeconds
    Seconds between consecutive dumps. Default: 5

.PARAMETER ExePathFilter
    Optional. Only target processes whose executable path contains this text.
    Use it when more than one Edge channel is running, e.g. "Edge\Application"
    for Stable or "Edge Beta" for Beta.

.PARAMETER SkipGpu
    Do not dump the GPU process.

.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File .\Collect-BrowserHangDump.ps1

.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File .\Collect-BrowserHangDump.ps1 -Browser Chrome

.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File .\Collect-BrowserHangDump.ps1 -ExePathFilter "Edge\Application"
#>
[CmdletBinding()]
param(
    [string]$ProcDumpPath = "C:\Dumps\procdump64.exe",
    [string]$OutputRoot   = "C:\Dumps",
    [ValidateSet("Edge", "Chrome")]
    [string]$Browser      = "Edge",
    [ValidateRange(1, 10)]
    [int]$DumpCount       = 3,
    [ValidateRange(1, 60)]
    [int]$IntervalSeconds = 5,
    [string]$ExePathFilter = "",
    [switch]$SkipGpu
)

$ErrorActionPreference = "Stop"

# ---------- Output folder and log ----------
$timeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outDir    = Join-Path $OutputRoot "$($Browser)Hang_$timeStamp"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$logFile   = Join-Path $outDir "collect.log"

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Write-Host $line -ForegroundColor $Color
    Add-Content -Path $logFile -Value $line
}

Write-Log "Output folder: $outDir" "Cyan"

# ---------- Pre-checks ----------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Log "WARNING: Not running as Administrator. Dumps may fail for processes of other users." "Yellow"
}

if (-not (Test-Path $ProcDumpPath)) {
    Write-Log "ERROR: ProcDump not found at '$ProcDumpPath'. Download it from https://learn.microsoft.com/sysinternals/downloads/procdump" "Red"
    exit 1
}

$drive = (Get-Item $OutputRoot).PSDrive
$freeGB = [math]::Round($drive.Free / 1GB, 1)
Write-Log "Free space on $($drive.Name): ${freeGB} GB"
if ($freeGB -lt 10) {
    Write-Log "WARNING: Less than 10 GB free. Full dumps can be several GB each." "Yellow"
}

# ---------- Find processes ----------
$exeName = if ($Browser -eq "Edge") { "msedge.exe" } else { "chrome.exe" }

$allProcs = @(Get-CimInstance Win32_Process -Filter "Name = '$exeName'")
if ($ExePathFilter) {
    $allProcs = @($allProcs | Where-Object { $_.ExecutablePath -like "*$ExePathFilter*" })
}

if ($allProcs.Count -eq 0) {
    Write-Log "ERROR: No $exeName process found. Is the browser still running?" "Red"
    exit 1
}

# Save a snapshot of all browser processes for later analysis
$allProcs |
    Select-Object ProcessId, ParentProcessId, CreationDate, ExecutablePath, CommandLine |
    Export-Csv -Path (Join-Path $outDir "process_list.csv") -NoTypeInformation -Encoding UTF8
Write-Log "Saved process snapshot ($($allProcs.Count) processes) to process_list.csv"

$browserProcs = @($allProcs | Where-Object { $_.CommandLine -and $_.CommandLine -notlike "*--type=*" })
$gpuProcs     = @($allProcs | Where-Object { $_.CommandLine -like "*--type=gpu-process*" })

if ($browserProcs.Count -eq 0) {
    Write-Log "ERROR: Browser process not found (command line may be unreadable; try running as Administrator)." "Red"
    exit 1
}
if ($browserProcs.Count -gt 1) {
    Write-Log "WARNING: Found $($browserProcs.Count) browser processes (multiple channels/profiles?). All of them will be dumped. Use -ExePathFilter to narrow down." "Yellow"
}

$targets = @()
foreach ($p in $browserProcs) {
    $targets += [pscustomobject]@{ Role = "browser"; ProcId = $p.ProcessId; Path = $p.ExecutablePath }
}
if (-not $SkipGpu) {
    if ($gpuProcs.Count -eq 0) {
        Write-Log "WARNING: GPU process not found. Only the browser process will be dumped." "Yellow"
    }
    foreach ($p in $gpuProcs) {
        $targets += [pscustomobject]@{ Role = "gpu"; ProcId = $p.ProcessId; Path = $p.ExecutablePath }
    }
}

foreach ($t in $targets) {
    Write-Log ("Target: {0,-8} PID={1,-7} {2}" -f $t.Role, $t.ProcId, $t.Path) "Green"
}

# ---------- Run ProcDump in parallel ----------
Write-Log "Starting ProcDump: $DumpCount full dump(s) per process, every $IntervalSeconds second(s). Do NOT close the browser." "Cyan"

$jobs = @()
foreach ($t in $targets) {
    $roleDir = Join-Path $outDir ("{0}_{1}" -f $t.Role, $t.ProcId)
    New-Item -ItemType Directory -Path $roleDir -Force | Out-Null
    $stdout = Join-Path $outDir ("procdump_{0}_{1}.txt" -f $t.Role, $t.ProcId)
    $stderr = Join-Path $outDir ("procdump_{0}_{1}_err.txt" -f $t.Role, $t.ProcId)

    $pdArgs = @("-accepteula", "-ma", "-n", $DumpCount, "-s", $IntervalSeconds, $t.ProcId, $roleDir)
    $proc = Start-Process -FilePath $ProcDumpPath -ArgumentList $pdArgs -NoNewWindow -PassThru `
                          -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    $jobs += [pscustomobject]@{ Target = $t; Proc = $proc; Dir = $roleDir }
}

foreach ($j in $jobs) {
    $j.Proc.WaitForExit()
    $dumps = @(Get-ChildItem -Path $j.Dir -Filter *.dmp -ErrorAction SilentlyContinue)
    $sizeGB = [math]::Round((($dumps | Measure-Object Length -Sum).Sum) / 1GB, 2)
    $color = if ($dumps.Count -ge $DumpCount) { "Green" } else { "Yellow" }
    Write-Log ("{0} PID {1}: ProcDump exit code {2}, {3} dump(s), {4} GB" -f `
        $j.Target.Role, $j.Target.ProcId, $j.Proc.ExitCode, $dumps.Count, $sizeGB) $color
}

# ---------- Basic environment info ----------
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $ver = (Get-Item ($browserProcs[0].ExecutablePath)).VersionInfo.ProductVersion
    @(
        "Collected : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
        "Computer  : $env:COMPUTERNAME"
        "User      : $env:USERNAME"
        "OS        : $($os.Caption) $($os.Version)"
        "Browser   : $Browser $ver"
    ) | Set-Content -Path (Join-Path $outDir "environment.txt") -Encoding UTF8
} catch {
    Write-Log "WARNING: Failed to collect environment info: $($_.Exception.Message)" "Yellow"
}

Write-Log "Done. You can now close the browser (End task if needed)." "Cyan"
Write-Log "Please compress and upload the whole folder: $outDir" "Cyan"
