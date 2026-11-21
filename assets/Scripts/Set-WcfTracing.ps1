<#
.SYNOPSIS
    Enables WCF activity, message, and network tracing in a .NET Framework
    configuration file, and restores the original file afterwards.

.DESCRIPTION
    Enable (default):
      1. Backs up the configuration file to <ConfigPath>.wcftrace.bak.
      2. Adds or replaces <system.diagnostics> under <configuration>.
      3. Adds or replaces <messageLogging> inside <system.serviceModel><diagnostics>,
         keeping any existing <diagnostics> settings. Uses the existing
         <system.serviceModel> and creates it only if it does not exist.
      4. Creates the log directory.
      5. Validates the result before overwriting the configuration file.

    Restore (-Restore):
      Copies the backup over the configuration file and deletes the backup,
      so the file is byte-for-byte identical to the original.

.PARAMETER ConfigPath
    Path to web.config or <app>.exe.config.

.PARAMETER LogDirectory
    Folder for the trace files. Default: C:\logs

.PARAMETER Restore
    Restore the original configuration from the backup.

.EXAMPLE
    .\Set-WcfTracing.ps1 -ConfigPath "C:\inetpub\wwwroot\MyService\web.config"

.EXAMPLE
    .\Set-WcfTracing.ps1 -ConfigPath "C:\inetpub\wwwroot\MyService\web.config" -Restore
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConfigPath,
    [string]$LogDirectory = 'C:\logs',
    [switch]$Restore
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
    throw "Configuration file not found: $ConfigPath"
}
$ConfigPath = (Resolve-Path -LiteralPath $ConfigPath).Path
$backupPath = "$ConfigPath.wcftrace.bak"

if ($Restore) {
    if (-not (Test-Path -LiteralPath $backupPath)) {
        throw "Backup not found: $backupPath. Nothing to restore."
    }
    Copy-Item -LiteralPath $backupPath -Destination $ConfigPath -Force
    Remove-Item -LiteralPath $backupPath -Force
    Write-Host "Restored        : $ConfigPath"
    Write-Host 'Restart the application or recycle its IIS app pool to apply the change.'
    return
}

if (Test-Path -LiteralPath $backupPath) {
    throw "Backup already exists: $backupPath. Tracing is probably already enabled. Run with -Restore first."
}

$logDir = [System.Security.SecurityElement]::Escape($LogDirectory.TrimEnd('\'))

$diagnosticsXml = @"
<system.diagnostics>
  <sources>
    <source name="System.ServiceModel" switchValue="Information, ActivityTracing" propagateActivity="true">
      <listeners>
        <add name="wcfActivity" />
      </listeners>
    </source>
    <source name="System.ServiceModel.MessageLogging">
      <listeners>
        <add name="wcfMessages" />
      </listeners>
    </source>
    <source name="System.Net" tracemode="protocolonly" maxdatasize="1024">
      <listeners>
        <add name="WcfNetTrace" />
      </listeners>
    </source>
    <source name="System.Net.Sockets" tracemode="protocolonly" maxdatasize="1024">
      <listeners>
        <add name="WcfNetTrace" />
      </listeners>
    </source>
  </sources>
  <switches>
    <add name="System.Net" value="Verbose" />
    <add name="System.Net.Sockets" value="Verbose" />
  </switches>
  <sharedListeners>
    <add name="wcfActivity" type="System.Diagnostics.XmlWriterTraceListener" initializeData="$logDir\wcf-activity.svclog" traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
    <add name="wcfMessages" type="System.Diagnostics.XmlWriterTraceListener" initializeData="$logDir\wcf-messages.svclog" traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
    <add name="WcfNetTrace" type="System.Diagnostics.TextWriterTraceListener" initializeData="$logDir\network.log" traceOutputOptions="DateTime, Timestamp, ProcessId, ThreadId" />
  </sharedListeners>
  <trace autoflush="true" />
</system.diagnostics>
"@

$messageLoggingXml = @'
<messageLogging logEntireMessage="false" logMalformedMessages="true" logMessagesAtServiceLevel="true" logMessagesAtTransportLevel="false" maxMessagesToLog="500" maxSizeOfMessageToLog="65536" />
'@

$doc = New-Object System.Xml.XmlDocument
$doc.PreserveWhitespace = $true
$doc.Load($ConfigPath)

$root = $doc.DocumentElement
if ($null -eq $root -or $root.LocalName -ne 'configuration') {
    throw 'The root element is not <configuration>.'
}
if ($root.NamespaceURI) {
    throw "The <configuration> element uses the XML namespace '$($root.NamespaceURI)'. Edit this file manually."
}

function Import-Fragment([string]$xml) {
    $fragment = New-Object System.Xml.XmlDocument
    $fragment.PreserveWhitespace = $true
    $fragment.LoadXml($xml)
    return $doc.ImportNode($fragment.DocumentElement, $true)
}

# <system.diagnostics>: replace if present, otherwise append to <configuration>.
$existing = $root.SelectSingleNode('system.diagnostics')
$newDiagnostics = Import-Fragment $diagnosticsXml
if ($existing) {
    [void]$root.ReplaceChild($newDiagnostics, $existing)
    Write-Host 'Replaced        : <system.diagnostics>'
}
else {
    [void]$root.AppendChild($newDiagnostics)
    Write-Host 'Added           : <system.diagnostics>'
}

# <system.serviceModel><diagnostics>: reuse the existing <system.serviceModel>.
$serviceModel = $root.SelectSingleNode('system.serviceModel')
if (-not $serviceModel) {
    $serviceModel = $root.AppendChild($doc.CreateElement('system.serviceModel'))
    Write-Host 'Added           : <system.serviceModel>'
}
$smDiagnostics = $serviceModel.SelectSingleNode('diagnostics')
if (-not $smDiagnostics) {
    $smDiagnostics = $serviceModel.AppendChild($doc.CreateElement('diagnostics'))
    Write-Host 'Added           : <system.serviceModel><diagnostics>'
}
# Keep existing <diagnostics> attributes and children; only set <messageLogging>.
$newMessageLogging = Import-Fragment $messageLoggingXml
$existingMessageLogging = $smDiagnostics.SelectSingleNode('messageLogging')
if ($existingMessageLogging) {
    [void]$smDiagnostics.ReplaceChild($newMessageLogging, $existingMessageLogging)
    Write-Host 'Replaced        : <diagnostics><messageLogging>'
}
else {
    [void]$smDiagnostics.AppendChild($newMessageLogging)
    Write-Host 'Added           : <diagnostics><messageLogging>'
}

# Write to a temporary file, validate it, then back up and replace the original.
$tempPath = "$ConfigPath.wcftrace.tmp"
$doc.Save($tempPath)
try {
    $check = New-Object System.Xml.XmlDocument
    $check.Load($tempPath)
}
catch {
    Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
    throw "The modified configuration is not valid XML. The original file was not changed. $_"
}

Copy-Item -LiteralPath $ConfigPath -Destination $backupPath
Move-Item -LiteralPath $tempPath -Destination $ConfigPath -Force

New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null

Write-Host "Backup          : $backupPath"
Write-Host "Log directory   : $LogDirectory"
Write-Host 'Restart the application or recycle its IIS app pool, then reproduce the issue.'
