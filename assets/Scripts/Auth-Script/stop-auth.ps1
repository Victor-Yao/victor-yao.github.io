<#
   ***Directory Services Authentication Scripts***

   Requires: PowerShell V4(Supported from Windows 8.1/Windows Server 2012 R2)

   Last Updated: 09/23/2022

   Version: 4.7
#>
#Requires -RunAsAdministrator
[cmdletbinding(PositionalBinding = $false)]
param(
    [string]$containerId
)

function Check-GMSA {
    param($ContainerId)

    $CredentialString = docker inspect -f "{{ .HostConfig.SecurityOpt }}" $ContainerId

    if ($CredentialString -ne "[]") {
        Write-Verbose "GMSA Credential String: $CredentialString"
        # NOTE(will): We need to check if we have RSAT installed
        if ((Get-Command "Test-ADServiceAccount" -ErrorAction "SilentlyContinue") -ne $null) {
            $ServiceAccountName = $(docker inspect -f "{{ .Config.Hostname }}" $ContainerId)
            $Result = "`nSTOP:`n`nRunning Test-ADServiceAccount $ServiceAccountName`nResult:"
            try {
                $Result += Test-ADServiceAccount -Identity $ServiceAccountName -Verbose -ErrorAction SilentlyContinue
            }
            catch {
                $Result += "Unable to find object with identity $containerId"
            }

            Out-File $_CONTAINER_DIR\gMSATest.txt -InputObject $Result -Append
        }

        $CredentialName = $CredentialString.Replace("[", "").Replace("]", "")
        $CredentialName = $CredentialName.Split("//")[-1]
        $CredentialObject = Get-CredentialSpec | Where-Object { $_.Name -eq $CredentialName }
        Copy-Item $CredentialObject.Path $_CONTAINER_DIR
    }
}

function Get-ContainersInfo {

    param($ContainerId)
    Get-NetFirewallProfile > $_CONTAINER_DIR\firewall_profile.txt
    Get-NetConnectionProfile >> $_CONTAINER_DIR\firewall_profile.txt
    netsh advfirewall firewall show rule name=* > $_CONTAINER_DIR\firewall_rules.txt
    netsh wfp show filters file=$_CONTAINER_DIR\wfpfilters.xml 2>&1 | Out-Null
    docker ps > $_CONTAINER_DIR\container-info.txt
    docker inspect $(docker ps -q) >> $_CONTAINER_DIR\container-info.txt
    docker network ls > $_CONTAINER_DIR\container-network-info.txt
    docker network inspect $(docker network ls -q) >> $_CONTAINER_DIR\container-network-info.txt

    docker top $containerId > $_CONTAINER_DIR\container-top.txt
    docker logs $containerId > $_CONTAINER_DIR\container-logs.txt

    wevtutil.exe set-log "Microsoft-Windows-Containers-CCG/Admin" /enabled:false 2>&1 | Out-Null
    wevtutil.exe export-log "Microsoft-Windows-Containers-CCG/Admin" $_CONTAINER_DIR\Containers-CCG_Admin.evtx /overwrite:true 2>&1 | Out-Null
    wevtutil.exe set-log "Microsoft-Windows-Containers-CCG/Admin" /enabled:true /rt:false /q:true 2>&1 | Out-Null
    Get-EventLog -LogName Application -Source Docker -After (Get-Date).AddMinutes(-30)  | Sort-Object Time | Export-CSV $_CONTAINER_DIR\docker_events.csv

}


function Invoke-Container {

    [Cmdletbinding(DefaultParameterSetName = "Default")]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ContainerId,
        [switch]$Nano,
        [Parameter(ParameterSetName = "PreTraceDir")]
        [switch]$PreTrace,
        [Parameter(ParameterSetName = "AuthDir")]
        [switch]$AuthDir,
        [switch]$UseCmd,
        [switch]$Record,
        [switch]$Silent,
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $Workingdir = "C:\AuthScripts"
    if ($PreTrace) {
        $Workingdir += "\authlogs\PreTraceLogs"
    }

    if ($AuthDir) {
        $Workingdir += "\authlogs"
    }

    Write-Verbose "Running Container command: $Command"
    if ($Record) {
        if ($Nano) {
            docker exec -u Administrator -w $Workingdir $ContainerId cmd /c "$Command" *>> $_CONTAINER_DIR\container-output.txt
        }
        elseif ($UseCmd) {
            docker exec -w $Workingdir $ContainerId cmd /c "$Command" *>> $_CONTAINER_DIR\container-output.txt
        }
        else {
            docker exec -w $Workingdir $ContainerId powershell -ExecutionPolicy Unrestricted "$Command" *>> $_CONTAINER_DIR\container-output.txt
        }
    }
    elseif ($Silent) {
        if ($Nano) {
            docker exec -u Administrator -w $Workingdir $ContainerId cmd /c "$Command" *>> Out-Null
        }
        elseif ($UseCmd) {
            docker exec -w $Workingdir $ContainerId cmd /c "$Command" *>> Out-Null
        }
        else {
            docker exec -w $Workingdir $ContainerId powershell -ExecutionPolicy Unrestricted "$Command" *>> Out-Null
        }
    }
    else {
        $Result = ""
        if ($Nano) {
            $Result = docker exec -u Administrator -w $Workingdir $ContainerId cmd /c "$Command"
        }
        elseif ($UseCmd) {
            $Result = docker exec -w $Workingdir $ContainerId cmd /c "$Command"
        }
        else {
            $Result = docker exec -w $Workingdir $ContainerId powershell -ExecutionPolicy Unrestricted "$Command"
        }
        return $Result
    }
}

function Stop-NanoTrace {
    param($ContainerId)

    Get-Content "$_CONTAINER_DIR\RunningProviders.txt" | ForEach-Object {
        Invoke-Container -ContainerId $ContainerId -Nano -AuthDir -Record -Command "wpr -stop $_`.etl -instancename $_"
    }

    # Cleaning up registry keys
    foreach ($RegDelete in $_REG_DELETE) {
        $DeleteParams = $RegDelete.Split("!")
        $DeleteKey = $DeleteParams[0]
        $DeleteValue = $DeleteParams[1]
        Invoke-Container -ContainerId $ContainerId -Nano -Record -Command "reg delete `"$DeleteKey`" /v $DeleteValue /f"
    }

    # Querying registry keys
    foreach ($RegQuery in $_REG_QUERY) {
        $QueryParams = $RegQuery.Split("!")
        $QueryKey = $QueryParams[0]
        $QueryOptions = $QueryParams[1]
        $QueryOutput = $QueryParams[2]

        $QueryOutput = "$QueryOutput`-key.txt"
        $AppendFile = Invoke-Container -ContainerId $ContainerId -AuthDir -Nano -Command "if exist $QueryOutput (echo True)"

        Write-Verbose "Append Result: $AppendFile"
        $Redirect = "> $QueryOutput"

        if ($AppendFile -eq "True") {
            $Redirect = ">> $QueryOutput"
        }


        if ($QueryOptions -eq "CHILDREN") {
            Invoke-Container -ContainerId $ContainerId -AuthDir -Nano -Record -Command "reg query `"$QueryKey`" /s $Redirect"
        }
        else {
            Invoke-Container -ContainerId $ContainerId -AuthDir -Nano -Record -Command "reg query `"$QueryKey`" $Redirect"
        }

    }

    foreach ($EventLog in $_EVENTLOG_LIST) {
        $EventLogParams = $EventLog.Split("!")
        $EventLogName = $EventLogParams[0]
        $EventLogOptions = $EventLogParams[1]

        $ExportName = $EventLogName.Replace("Microsoft-Windows-", "").Replace(" ", "_").Replace("/", "_")

        if ($EventLogOptions -ne "DEFAULT") {
            Invoke-Container -ContainerId $ContainerId -Nano -Record -Command "wevtutil set-log $EventLogName /enabled:false"
        }

        Invoke-Container -ContainerId $ContainerId -Nano -Record -AuthDir -Command "wevtutil export-log $EventLogName $ExportName.evtx /overwrite:true"

        if ($EventLogOptions -eq "ENABLE") {
            Invoke-Container -ContainerId $ContainerId -Nano -Record -Command "wevtutil set-log $EventLogName /enabled:true /rt:false" *>> $_CONTAINER_DIR\container-output.txt
        }
    }
}


[float]$_Authscriptver = "4.7"
$_BASE_LOG_DIR = ".\authlogs"
$_LOG_DIR = $_BASE_LOG_DIR
$_CH_LOG_DIR = "$_BASE_LOG_DIR\container-host"
$_BASE_C_DIR = "$_BASE_LOG_DIR`-container"
$_C_LOG_DIR = "$_BASE_LOG_DIR\container"


$_EVENTLOG_LIST = @(
    # LOGNAME!FLAGS
    "Application!DEFAULT"
    "System!DEFAULT"
    "Microsoft-Windows-CAPI2/Operational!NONE"
    "Microsoft-Windows-Kerberos/Operational!NONE"
    "Microsoft-Windows-Kerberos-key-Distribution-Center/Operational!NONE"
    "Microsoft-Windows-Kerberos-KdcProxy/Operational!NONE"
    "Microsoft-Windows-WebAuth/Operational!NONE"
    "Microsoft-Windows-WebAuthN/Operational!ENABLE"
    "Microsoft-Windows-CertPoleEng/Operational!NONE"
    "Microsoft-Windows-IdCtrls/Operational!ENABLE"
    "Microsoft-Windows-User Control Panel/Operational!NONE"
    "Microsoft-Windows-Authentication/AuthenticationPolicyFailures-DomainController!NONE"
    "Microsoft-Windows-Authentication/ProtectedUser-Client!NONE"
    "Microsoft-Windows-Authentication/ProtectedUserFailures-DomainController!NONE"
    "Microsoft-Windows-Authentication/ProtectedUserSuccesses-DomainController!NONE"
    "Microsoft-Windows-Biometrics/Operational!ENABLE"
    "Microsoft-Windows-LiveId/Operational!ENABLE"
    "Microsoft-Windows-AAD/Analytic!NONE"
    "Microsoft-Windows-AAD/Operational!ENABLE"
    "Microsoft-Windows-User Device Registration/Debug!NONE"
    "Microsoft-Windows-User Device Registration/Admin!ENABLE"
    "Microsoft-Windows-HelloForBusiness/Operational!ENABLE"
    "Microsoft-Windows-Shell-Core/Operational!ENABLE"
    "Microsoft-Windows-WMI-Activity/Operational!ENABLE"
    "Microsoft-Windows-GroupPolicy/Operational!DEFAULT"
    "Microsoft-Windows-Crypto-DPAPI/Operational!ENABLE"
    "Microsoft-Windows-Containers-CCG/Admin!ENABLE"
    "Microsoft-Windows-CertificateServicesClient-Lifecycle-System/Operational!ENABLE"
    "Microsoft-Windows-CertificateServicesClient-Lifecycle-User/Operational!ENABLE"
)

# Reg Delete
$_REG_DELETE = @(
    # KEY!NAME
    "HKLM\SYSTEM\CurrentControlSet\Control\LSA!SPMInfoLevel"
    "HKLM\SYSTEM\CurrentControlSet\Control\LSA!LogToFile"
    "HKLM\SYSTEM\CurrentControlSet\Control\LSA!NegEventMask"
    "HKLM\SYSTEM\CurrentControlSet\Control\LSA\NegoExtender\Parameters!InfoLevel"
    "HKLM\SYSTEM\CurrentControlSet\Control\LSA\Pku2u\Parameters!InfoLevel"
    "HKLM\SYSTEM\CurrentControlSet\Control\LSA!LspDbgInfoLevel"
    "HKLM\SYSTEM\CurrentControlSet\Control\LSA!LspDbgTraceOptions"
    "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Diagnostics!GPSvcDebugLevel"
)

# Reg Query
$_REG_QUERY = @(
    # KEY!CHILD!FILENAME
    # File will be written ending with <FILENAME>-key.txt
    # If the export already exists it will be appended
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa!CHILDREN!Lsa"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies!CHILDREN!Polices"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System!CHILDREN!SystemGP"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer!CHILDREN!Lanmanserver"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation!CHILDREN!Lanmanworkstation"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon!CHILDREN!Netlogon"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL!CHILDREN!Schannel"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Cryptography!CHILDREN!Cryptography-HKLMControl"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography!CHILDREN!Cryptography-HKLMSoftware"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Cryptography!CHILDREN!Cryptography-HKLMSoftware-Policies"
    "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Cryptography!CHILDREN!Cryptography-HKCUSoftware-Policies"
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Cryptography!CHILDREN!Cryptography-HKCUSoftware"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\SmartCardCredentialProvider!CHILDREN!SCardCredentialProviderGP"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication!CHILDREN!Authentication"
    "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Authentication!CHILDREN!Authentication-Wow64"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon!CHILDREN!Winlogon"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Winlogon!CHILDREN!Winlogon-CCS"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IdentityStore!CHILDREN!Idstore-Config"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IdentityCRL!CHILDREN!Idstore-Config"
    "HKEY_USERS\.Default\Software\Microsoft\IdentityCRL!CHILDREN!Idstore-Config"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Kdc!CHILDREN!KDC"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\KPSSVC!CHILDREN!KDCProxy"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CloudDomainJoin!CHILDREN!RegCDJ"
    "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\WorkplaceJoin!CHILDREN!RegWPJ"
    "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\WorkplaceJoin\AADNGC!CHILDREN!RegAADNGC"
    "HKEY_LOCAL_MACHINE\Software\Policies\Windows\WorkplaceJoin!CHILDREN!REGWPJ-Policy"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Winbio!CHILDREN!Wbio"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WbioSrvc!CHILDREN!Wbiosrvc"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Biometrics!CHILDREN!Wbio-Policy"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\EAS\Policies!CHILDREN!EAS"
    "HKEY_CURRENT_USER\SOFTWARE\Microsoft\SCEP!CHILDREN!Scep"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SQMClient!CHILDREN!MachineId"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Policies\PassportForWork!CHILDREN!NgcPolicyIntune"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PassportForWork!CHILDREN!NgcPolicyGp"
    "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\PassportForWork!CHILDREN!NgcPolicyGpUser"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Cryptography\Ngc!CHILDREN!NgcCryptoConfig"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\DeviceLock!CHILDREN!DeviceLockPolicy"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Policies\PassportForWork\SecurityKey!CHILDREN!FIDOPolicyIntune"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\FIDO!CHILDREN!FIDOGp"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Rpc!CHILDREN!RpcGP"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NTDS\Parameters!CHILDREN!NTDS"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LDAP!CHILDREN!LdapClient"
    "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard!CHILDREN!DeviceGuard"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CCMSetup!CHILDREN!CCMSetup"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CCM!CHILDREN!CCM"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v2.0.50727!NONE!DotNET-TLS"
    "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319!NONE!DotNET-TLS"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319!NONE!DotNET-TLS"
    "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727!NONE!DotNET-TLS"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedPC!NONE!SharedPC"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess!NONE!Passwordless"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Authz!CHILDREN!Authz"
    "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp!NONE!WinHttp-TLS"
    "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp!NONE!WinHttp-TLS"
    "HKEY_LOCAL_MACHINE\Software\Microsoft\Enrollments!CHILDREN!MDMEnrollments"
    "HKEY_LOCAL_MACHINE\Software\Microsoft\EnterpriseResourceManager!CHILDREN!MDMEnterpriseResourceManager"
    "HKEY_CURRENT_USER\Software\Microsoft\SCEP!CHILDREN!MDMSCEP-User"
    "HKEY_CURRENT_USER\S-1-5-18\Software\Microsoft\SCEP!CHILDREN!MDMSCEP-SystemUser"
)

if ($containerId -ne "") {
    $_CONTAINER_DIR = "$_BASE_C_DIR`-$containerId"

    if (!(Test-Path "$_CONTAINER_DIR\started.txt")) {
        Write-Host "
===== Microsoft CSS Authentication Scripts started tracing =====`n
We have detected that tracing has not been started in container $containerId.
Please run start-auth.ps1 -containerId $containerId to start the tracing.`n"
        return
    }

    Write-Verbose "Stopping Container auth scripts"
    $RunningContainers = $(docker ps -q)
    if ($containerId -in $RunningContainers) {
        Write-Verbose "$containerId Found"
        Write-Host "Stopping data collection..."
        if ((Get-Content $_CONTAINER_DIR\container-base.txt) -eq "Nano") {
            Write-Verbose "Stopping Nano container data collection"
            # NOTE(will) Stop the wprp
            Stop-NanoTrace -ContainerId $containerId
        }
        else {
            Write-Verbose "Stopping Standard container data collection"
            Invoke-Container -ContainerId $containerId -Record -Command ".\stop-auth.ps1"
        }
    }
    else {
        Write-Host "Failed to find $containerId"
        return
    }

    Write-Host "`nCollecting Container Host Device configuration information, please wait....`n"
    Check-GMSA -ContainerId $containerId
    Get-ContainersInfo -ContainerId $containerId

    # Stop Pktmon
    if ((Get-HotFix | Where-Object { $_.HotFixID -gt "KB5000854" -and $_.Description -eq "Update" } | Measure-object).Count -ne 0) {
        pktmon stop 2>&1 | Out-Null
        pktmon list -a > $_CONTAINER_DIR\pktmon_components.txt
    }
    else {
        netsh trace stop | Out-Null
    }

    Add-Content -Path $_CONTAINER_DIR\script-info.txt -Value ("Data collection stopped on: " + (Get-Date -Format "yyyy/MM/dd HH:mm:ss"))
    Remove-Item -Path $_CONTAINER_DIR\started.txt -Force | Out-Null

    Write-Host "`n
===== Microsoft CSS Authentication Scripts tracing stopped =====`n
The tracing has now stopped. Please copy the collected data to the logging directory`n"

    Write-Host "Example:
`tdocker stop $containerId
`tdocker cp $containerId`:\AuthScripts\authlogs $_CONTAINER_DIR
`tdocker start $containerId" -ForegroundColor Yellow

    Write-Host "`n
======================= IMPORTANT NOTICE =======================`n
The authentication script is designed to collect information that will help Microsoft Customer Support Services (CSS) troubleshoot an issue you may be experiencing with Windows.
The collected data may contain Personally Identifiable Information (PII) and/or sensitive data, such as (but not limited to) IP addresses, Device names, and User names.`n
Once the tracing and data collection has completed, the script will save the data in a subdirectory from where this script is launched called ""$_CONTAINER_DIR"".
The ""$_CONTAINER_DIR"" directory and subdirectories will contain data collected by the Microsoft CSS Authentication scripts.
This folder and its contents are not automatically sent to Microsoft.
You can send this folder and its contents to Microsoft CSS using a secure file transfer tool - Please discuss this with your support professional and also any concerns you may have.`n"
    return
}

# *** Check if script is running ***
If (!(Test-Path $_LOG_DIR\started.txt) -eq "True") {
    Write-Host "
===== Microsoft CSS Authentication Scripts started tracing =====`n
We have detected that tracing has not been started.
Please run start-auth.ps1 to start the tracing.`n"
    exit
}

# Replaced with #Requires -RunAsAdministrator
## *** Check for elevation ***
#Write-Host "`nChecking token for Elevation - please wait..."
#
#If((whoami /groups) -match "S-1-16-12288"){
#Write-Host "`nToken elevated"}
#Else{
#Write-Host
#"============= Microsoft CSS Authentication Scripts =============`n
#The script must be run from an elevated Powershell console.
#The script has detected that it is not being run from an elevated PowerShell console.`n
#Please run the script from an elevated PowerShell console.`n"
#exit
#}

# *** Disclaimer ***
Write-Host "`n
***************** Microsoft CSS Authentication Scripts ****************`n
This Data collection is for Authentication, smart card and Credential provider scenarios.`n
This script will stop the tracing that was previously activated with the start-auth.ps1 script.
Data is collected into a subdirectory of the directory from where this script is launched, called ""authlogs"".`n
Please wait whilst the tracing stops and data is collected....
"


$ProductType = (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\ProductOptions).ProductType

# ***STOP LOGMAN TRACING***
$NGCSingleTraceName = "NGC"
$BiometricSingleTraceName = "Biometric"
$LSASingleTraceName = "LSA"
$Ntlm_CredSSPSingleTraceName = "Ntlm_CredSSP"
$KerberosSingleTraceName = "Kerberos"
$KDCSingleTraceName = "KDC"
$SSLSingleTraceName = "SSL"
$WebauthSingleTraceName = "Webauth"
$SmartcardSingleTraceName = "Smartcard"
$CredprovAuthuiSingleTraceName = "CredprovAuthui"
$CryptNcryptDpapiSingleTraceName = "CryptNcryptDpapi"
$SAMSingleTraceName = "SAM"
$KernelSingleTraceName = "NT Kernel Logger"

$_WAM_LOG_DIR = "$_LOG_DIR\WAM"
$_SCCM_LOG_DIR = "$_LOG_DIR\SCCM-enrollment"
$_MDM_LOG_DIR = "$_LOG_DIR\DeviceManagement_and_MDM"
$_CERT_LOG_DIR = "$_LOG_DIR\Certinfo_and_Certenroll"

New-Item -Path $_WAM_LOG_DIR -ItemType Directory | Out-Null
New-Item -Path $_SCCM_LOG_DIR -ItemType Directory | Out-Null
New-Item -Path $_MDM_LOG_DIR -ItemType Directory | Out-Null
New-Item -Path $_CERT_LOG_DIR -ItemType Directory | Out-Null

Add-Content -Path $_LOG_DIR\Tasklist.txt -Value (tasklist /svc 2>&1) | Out-Null
Add-Content -Path $_LOG_DIR\Tickets.txt -Value(klist) | Out-Null
Add-Content -Path $_LOG_DIR\Tickets-localsystem.txt -Value (klist -li 0x3e7) | Out-Null
Add-Content -Path $_LOG_DIR\Klist-Cloud-Debug.txt -Value (klist Cloud_debug) | Out-Null

# Stop NGC logman
logman stop $NGCSingleTraceName -ets

# Stop Biometric logman
logman stop $BiometricSingleTraceName -ets

# Stop LSA logman
logman stop $LSASingleTraceName -ets

# Stop Ntlm_CredSSP logman
logman stop $Ntlm_CredSSPSingleTraceName -ets

# Stop Kerberos logman
logman stop $KerberosSingleTraceName -ets

# Stop KDC logman
if ($ProductType -eq "LanmanNT") { logman stop $KDCSingleTraceName -ets }

# Stop SSL logman
logman stop $SSLSingleTraceName -ets

# Stop Webauth logman
logman stop $WebauthSingleTraceName -ets

# Stop Smartcard logman
logman stop $SmartcardSingleTraceName -ets

# Stop CredprovAuthui logman
logman stop $CredprovAuthuiSingleTraceName -ets

# Stop CryptNcryptDpapi logman
if ($ProductType -eq "WinNT") { logman stop $CryptNcryptDpapiSingleTraceName -ets }

# Stop SAM logman
logman stop $SAMSingleTraceName -ets



# Stop Kernel logman
if ($ProductType -eq "WinNT") { logman stop $KernelSingleTraceName -ets }

# ***CLEAN UP ADDITIONAL LOGGING***
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA /v SPMInfoLevel /f  2>&1 | Out-Null
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA /v LogToFile /f  2>&1 | Out-Null
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA /v NegEventMask /f  2>&1 | Out-Null
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA\NegoExtender\Parameters /v InfoLevel /f  2>&1 | Out-Null
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA\Pku2u\Parameters /v InfoLevel /f  2>&1 | Out-Null
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA /v LspDbgInfoLevel /f  2>&1 | Out-Null
reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA /v LspDbgTraceOptions /f  2>&1 | Out-Null

if ($ProductType -eq "WinNT") {
    reg delete HKLM\SYSTEM\CurrentControlSet\Control\LSA\Kerberos\Parameters /v LogLevel /f  2>&1 | Out-Null
}

reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Diagnostics" /v GPSvcDebugLevel /f  2>&1 | Out-Null
nltest /dbflag:0x0  2>&1 | Out-Null


# *** Event/Operational logs

wevtutil.exe set-log "Microsoft-Windows-CAPI2/Operational" /enabled:false  2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-CAPI2/Operational" $_LOG_DIR\Capi2_Oper.evtx /overwrite:true  2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-Kerberos/Operational" /enabled:false  2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-Kerberos/Operational" $_LOG_DIR\Kerb_Oper.evtx /overwrite:true  2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-Kerberos-key-Distribution-Center/Operational" /enabled:false  2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-Kerberos-key-Distribution-Center/Operational" $_LOG_DIR\Kdc_Oper.evtx /overwrite:true  2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-Kerberos-KdcProxy/Operational" /enabled:false  2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-Kerberos-KdcProxy/Operational" $_LOG_DIR\KdcProxy_Oper.evtx /overwrite:true  2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-WebAuth/Operational" /enabled:false  2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-WebAuth/Operational" $_LOG_DIR\WebAuth_Oper.evtx /overwrite:true  2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-WebAuthN/Operational" /enabled:false  2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-WebAuthN/Operational" $_LOG_DIR\\WebAuthn_Oper.evtx /overwrite:true  2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-WebAuthN/Operational" /enabled:true /rt:false /q:true  2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-CertPoleEng/Operational" /enabled:false  2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-CertPoleEng/Operational" $_LOG_DIR\Certpoleng_Oper.evtx /overwrite:true  2>&1 | Out-Null

wevtutil query-events Application "/q:*[System[Provider[@Name='Microsoft-Windows-CertificateServicesClient-CertEnroll']]]" > $_CERT_LOG_DIR\CertificateServicesClientLog.xml 2>&1 | Out-Null
certutil -policycache $_LOG_DIR\CertificateServicesClientLog.xml > $_LOG_DIR\ReadableClientLog.txt 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-IdCtrls/Operational" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-IdCtrls/Operational" $_LOG_DIR\Idctrls_Oper.evtx /overwrite:true 2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-IdCtrls/Operational" /enabled:true /rt:false /q:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-User Control Panel/Operational"  /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-User Control Panel/Operational" $_LOG_DIR\UserControlPanel_Oper.evtx /overwrite:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-Authentication/AuthenticationPolicyFailures-DomainController" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-Authentication/AuthenticationPolicyFailures-DomainController" $_LOG_DIR\Auth_Policy_Fail_DC.evtx /overwrite:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-Authentication/ProtectedUser-Client" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-Authentication/ProtectedUser-Client" $_LOG_DIR\Auth_ProtectedUser_Client.evtx /overwrite:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-Authentication/ProtectedUserFailures-DomainController" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-Authentication/ProtectedUserFailures-DomainController" $_LOG_DIR\Auth_ProtectedUser_Fail_DC.evtx /overwrite:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-Authentication/ProtectedUserSuccesses-DomainController" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-Authentication/ProtectedUserSuccesses-DomainController" $_LOG_DIR\Auth_ProtectedUser_Success_DC.evtx /overwrite:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-Biometrics/Operational" /enabled:false  2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-Biometrics/Operational" $_LOG_DIR\WinBio_oper.evtx /overwrite:true  2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-Biometrics/Operational" /enabled:true /rt:false /q:true  2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-LiveId/Operational" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-LiveId/Operational" $_LOG_DIR\LiveId_Oper.evtx /overwrite:true 2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-LiveId/Operational" /enabled:true /rt:false /q:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-AAD/Analytic" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-AAD/Analytic" $_LOG_DIR\Aad_Analytic.evtx /overwrite:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-AAD/Operational" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-AAD/Operational" $_LOG_DIR\Aad_Oper.evtx /overwrite:true 2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-AAD/Operational"  /enabled:true /rt:false /q:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-User Device Registration/Debug" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-User Device Registration/Debug" $_LOG_DIR\UsrDeviceReg_Dbg.evtx /overwrite:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-User Device Registration/Admin" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-User Device Registration/Admin" $_LOG_DIR\UsrDeviceReg_Adm.evtx /overwrite:true 2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-User Device Registration/Admin" /enabled:true /rt:false /q:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-HelloForBusiness/Operational" /enabled:false  2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-HelloForBusiness/Operational" $_LOG_DIR\Hfb_Oper.evtx /overwrite:true  2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-HelloForBusiness/Operational" /enabled:true /rt:false /q:true  2>&1 | Out-Null

wevtutil.exe export-log SYSTEM $_LOG_DIR\System.evtx /overwrite:true  2>&1 | Out-Null
wevtutil.exe export-log APPLICATION $_LOG_DIR\Application.evtx /overwrite:true  2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-Shell-Core/Operational" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-Shell-Core/Operational" $_LOG_DIR\ShellCore_Oper.evtx /overwrite:true 2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-Shell-Core/Operational" /enabled:true /rt:false /q:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-WMI-Activity/Operational" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-WMI-Activity/Operational" $_LOG_DIR\WMI-Activity_Oper.evtx /overwrite:true 2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-WMI-Activity/Operational" /enabled:true /rt:false /q:true 2>&1 | Out-Null

wevtutil.exe export-log "Microsoft-Windows-GroupPolicy/Operational" $_LOG_DIR\GroupPolicy.evtx /overwrite:true  2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-Crypto-DPAPI/Operational" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-Crypto-DPAPI/Operational" $_LOG_DIR\DPAPI_Oper.evtx /overwrite:true 2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-Crypto-DPAPI/Operational" /enabled:true /rt:false /q:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-Containers-CCG/Admin" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-Containers-CCG/Admin" $_LOG_DIR\Containers-CCG_Admin.evtx /overwrite:true 2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-Containers-CCG/Admin" /enabled:true /rt:false /q:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-CertificateServicesClient-Lifecycle-System/Operational" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-CertificateServicesClient-Lifecycle-System/Operational" $_LOG_DIR\CertificateServicesClient-Lifecycle-System_Oper.evtx /overwrite:true 2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-CertificateServicesClient-Lifecycle-System/Operational" /enabled:true /rt:false /q:true 2>&1 | Out-Null

wevtutil.exe set-log "Microsoft-Windows-CertificateServicesClient-Lifecycle-User/Operational" /enabled:false 2>&1 | Out-Null
wevtutil.exe export-log "Microsoft-Windows-CertificateServicesClient-Lifecycle-User/Operational" $_LOG_DIR\CertificateServicesClient-Lifecycle-User_Oper.evtx /overwrite:true 2>&1 | Out-Null
wevtutil.exe set-log "Microsoft-Windows-CertificateServicesClient-Lifecycle-User/Operational" /enabled:true /rt:false /q:true 2>&1 | Out-Null

# ***COLLECT NGC DETAILS***
Add-Content -Path $_LOG_DIR\Dsregcmd.txt -Value (dsregcmd /status 2>&1) | Out-Null
Add-Content -Path $_LOG_DIR\Dsregcmddebug.txt -Value (dsregcmd /status /debug /all 2>&1) | Out-Null

certutil -delreg Enroll\Debug  2>&1 | Out-Null
certutil -delreg ngc\Debug  2>&1 | Out-Null
certutil -delreg Enroll\LogLevel  2>&1 | Out-Null

Copy-Item -Path "$($env:windir)\Ngc*.log" -Destination $_LOG_DIR -Force 2>&1 | Out-Null
Get-ChildItem -Path $_LOG_DIR -Filter "Ngc*.log" | Rename-Item -NewName { "Pregenlog_" + $_.Name } 2>&1 | Out-Null

Copy-Item -Path "$($env:LOCALAPPDATA)\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy\settings\settings.dat" -Destination $_WAM_LOG_DIR\settings.dat -Force 2>&1 | Out-Null

if ((Test-Path "$($env:LOCALAPPDATA)\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy\AC\TokenBroker\Accounts\") -eq "True") {
    $WAMAccountsFullPath = GCI "$($env:LOCALAPPDATA)\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy\AC\TokenBroker\Accounts\*.tbacct"
    foreach ($WAMAccountsFile in $WAMAccountsFullPath) {
        "File Name: " + $WAMAccountsFile.name + "`n" >> $_WAM_LOG_DIR\tbacct.txt
        Get-content -Path $WAMAccountsFile.FullName >> $_WAM_LOG_DIR\tbacct.txt -Encoding Unicode | Out-Null
        "`n`n" >> $_WAM_LOG_DIR\tbacct.txt
    }
}

#checking if Network trace is running
$CheckIfNonetWasPassed = get-content $_LOG_DIR\script-info.txt | Select-String -pattern "nonet"
if ($CheckIfNonetWasPassed.Pattern -ne "nonet") {
    Write-Host "`n
    Stopping Network Trace and merging
    This may take some time depending on the size of the network capture, please wait....`n"

    # Stop Network Trace
    netsh trace stop 2>&1 | Out-Null
}

Add-Content -Path $_LOG_DIR\Ipconfig-info.txt -Value (ipconfig /all 2>&1) | Out-Null
Add-Content -Path $_LOG_DIR\Displaydns.txt -Value (ipconfig /displaydns 2>&1) | Out-Null
Add-Content -Path $_LOG_DIR\netstat.txt -Value (netstat -ano 2>&1) | Out-Null

# ***Netlogon, LSASS, LSP, Netsetup and Gpsvc log***
Copy-Item -Path "$($env:windir)\debug\Netlogon.*" -Destination $_LOG_DIR -Force 2>&1 | Out-Null
Copy-Item -Path "$($env:windir)\system32\Lsass.log" -Destination $_LOG_DIR -Force 2>&1 | Out-Null
Copy-Item -Path "$($env:windir)\debug\Lsp.*" -Destination $_LOG_DIR -Force 2>&1 | Out-Null
Copy-Item -Path "$($env:windir)\debug\Netsetup.log" -Destination $_LOG_DIR -Force 2>&1 | Out-Null
Copy-Item -Path "$($env:windir)\debug\usermode\gpsvc.*" -Destination $_LOG_DIR -Force 2>&1 | Out-Null

# ***Credman***
Add-Content -Path $_LOG_DIR\Credman.txt -Value (cmdkey.exe /list 2>&1) | Out-Null

# ***Build info***
$ProductName = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").ProductName
$DisplayVersion = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").DisplayVersion
$InstallationType = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").InstallationType
$CurrentVersion = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").CurrentVersion
$ReleaseId = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").ReleaseId
$BuildLabEx = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").BuildLabEx
$CurrentBuildHex = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").CurrentBuild
$UBRHEX = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion").UBR

Add-Content -Path $_LOG_DIR\Build.txt -Value ($env:COMPUTERNAME + " " + $ProductName + " " + $InstallationType + " Version:" + $CurrentVersion + " " + $DisplayVersion + " Build:" + $CurrentBuildHex + "." + $UBRHEX) | Out-Null
Add-Content -Path $_LOG_DIR\Build.txt -Value ("-------------------------------------------------------------------") | Out-Null
Add-Content -Path $_LOG_DIR\Build.txt -Value ("BuildLabEx: " + $BuildLabEx) | Out-Null
Add-Content -Path $_LOG_DIR\Build.txt -Value ("---------------------------------------------------") | Out-Null

# ***Reg Exports***
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /s > $_LOG_DIR\Lsa-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies" /s > $_LOG_DIR\Policies-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System" /s > $_LOG_DIR\SystemGP-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer" /s > $_LOG_DIR\Lanmanserver-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" /s > $_LOG_DIR\Lanmanworkstation-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon" /s > $_LOG_DIR\Netlogon-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL" /s > $_LOG_DIR\Schannel-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Cryptography" /s > $_LOG_DIR\Cryptography-HKLMControl-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography" /s > $_LOG_DIR\Cryptography-HKLMSoftware-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Cryptography" /s > $_LOG_DIR\Cryptography-HKLMSoftware-Policies-key.txt 2>&1 | Out-Null

reg query "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Cryptography" /s > $_LOG_DIR\Cryptography-HKCUSoftware-Policies-key.txt 2>&1 | Out-Null
reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Cryptography" /s > $_LOG_DIR\Cryptography-HKCUSoftware-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\SmartCardCredentialProvider" /s > $_LOG_DIR\SCardCredentialProviderGP-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication" /s > $_LOG_DIR\Authentication-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Authentication" /s > $_LOG_DIR\Authentication-key-Wow64.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /s > $_LOG_DIR\Winlogon-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Winlogon" /s > $_LOG_DIR\Winlogon-CCS-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IdentityStore" /s > $_LOG_DIR\Idstore-Config-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\IdentityCRL" /s >> $_LOG_DIR\Idstore-Config-key.txt 2>&1 | Out-Null
reg query "HKEY_USERS\.Default\Software\Microsoft\IdentityCRL" /s >> $_LOG_DIR\Idstore-Config-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Kdc" /s > $_LOG_DIR\KDC-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\KPSSVC" /s > $_LOG_DIR\KDCProxy-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CloudDomainJoin" /s > $_LOG_DIR\RegCDJ-key.txt 2>&1 | Out-Null
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\WorkplaceJoin" /s > $_LOG_DIR\Reg-WPJ-key.txt 2>&1 | Out-Null
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\WorkplaceJoin\AADNGC" /s > $_LOG_DIR\RegAADNGC-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\Software\Policies\Windows\WorkplaceJoin" /s > $_LOG_DIR\Reg-WPJ-Policy-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Winbio" /s > $_LOG_DIR\Winbio-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WbioSrvc" /s > $_LOG_DIR\Wbiosrvc-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Biometrics" /s > $_LOG_DIR\Winbio-Policy-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\EAS\Policies" /s > $_LOG_DIR\Eas-key.txt 2>&1 | Out-Null

reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\SCEP" /s > $_LOG_DIR\Scep-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SQMClient" /s > $_LOG_DIR\MachineId.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Policies\PassportForWork" /s > $_LOG_DIR\NgcPolicyIntune-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PassportForWork" /s > $_LOG_DIR\NgcPolicyGp-key.txt 2>&1  | Out-Null
reg query "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\PassportForWork" /s > $_LOG_DIR\NgcPolicyGpUser-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Cryptography\Ngc" /s > $_LOG_DIR\NgcCryptoConfig-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\DeviceLock" /s > $_LOG_DIR\DeviceLockPolicy-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Policies\PassportForWork\SecurityKey " /s > $_LOG_DIR\FIDOPolicyIntune-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\FIDO" /s > $_LOG_DIR\FIDOGp-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Rpc" /s > $_LOG_DIR\RpcGP-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NTDS\Parameters" /s > $_LOG_DIR\NTDS-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LDAP" /s > $_LOG_DIR\LdapClient-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard" /s > $_LOG_DIR\DeviceGuard-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CCMSetup" /s > $_SCCM_LOG_DIR\CCMSetup-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\CCM" /s > $_SCCM_LOG_DIR\CCM-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v2.0.50727" > $_LOG_DIR\DotNET-TLS-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319" >> $_LOG_DIR\DotNET-TLS-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" >> $_LOG_DIR\DotNET-TLS-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727" >> $_LOG_DIR\DotNET-TLS-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedPC" > $_LOG_DIR\SharedPC.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess" > $_LOG_DIR\Passwordless.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Authz" /s > $_LOG_DIR\Authz-key.txt 2>&1 | Out-Null

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp" > $_LOG_DIR\WinHttp-TLS-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp" >> $_LOG_DIR\WinHttp-TLS-key.txt 2>&1 | Out-Null

Add-Content -Path $_LOG_DIR\http-show-sslcert.txt -Value (netsh http show sslcert 2>&1) | Out-Null
Add-Content -Path $_LOG_DIR\http-show-urlacl.txt -Value (netsh http show urlacl 2>&1) | Out-Null

Add-Content -Path $_LOG_DIR\trustinfo.txt -Value (nltest /DOMAIN_TRUSTS /ALL_TRUSTS /V 2>&1) | Out-Null

$domain = (Get-WmiObject Win32_ComputerSystem).Domain
switch ($ProductType) {
    "WinNT" {
        Add-Content -Path $_LOG_DIR\SecureChannel.txt -Value (nltest /sc_query:$domain 2>&1) | Out-Null
    }
    "ServerNT" {
        Add-Content -Path $_LOG_DIR\SecureChannel.txt -Value (nltest /sc_query:$domain 2>&1) | Out-Null
    }
}

# ***Cert info***
Add-Content -Path $_CERT_LOG_DIR\Machine-Store.txt -Value (certutil -v -silent -store my 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\User-Store.txt -Value (certutil -v -silent -user -store my 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Scinfo.txt -Value (Certutil -v -silent -scinfo 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Tpm-Cert-Info.txt -Value (certutil -tpminfo 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\CertMY_SmartCard.txt -Value (certutil -v -silent -user -store my "Microsoft Smart Card Key Storage Provider" 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Cert_MPassportKey.txt -Value (Certutil -v -silent -user -key -csp "Microsoft Passport Key Storage Provider" 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Homegroup-Machine-Store.txt -Value (certutil -v -silent -store "Homegroup Machine Certificates" 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\NTAuth-store.txt -Value (certutil -v -enterprise -store NTAuth 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Machine-Root-AD-store.txt -Value (certutil -v -store -enterprise root 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Machine-Root-Registry-store.txt -Value (certutil -v -store root 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Machine-Root-GP-Store.txt -Value (certutil -v -silent -store -grouppolicy root 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Machine-Root-ThirdParty-Store.txt -Value (certutil -v -store authroot 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Machine-CA-AD-store.txt -Value (certutil -v -store -enterprise ca 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Machine-CA-Registry-store.txt -Value (certutil -v -store ca 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Machine-CA-GP-Store.txt -Value (certutil -v -silent -store -grouppolicy ca 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Cert-template-cache-machine.txt -Value (certutil -v -template 2>&1) | Out-Null
Add-Content -Path $_CERT_LOG_DIR\Cert-template-cache-user.txt -Value (certutil -v -template -user 2>&1) | Out-Null


# *** Cert enrolment info
Copy-Item "$($env:windir)\CertEnroll.log" -Destination $_CERT_LOG_DIR\CertEnroll-fromWindir.log -Force 2>&1 | Out-Null

Copy-Item "$($env:windir)\certmmc.log" -Destination $_CERT_LOG_DIR\CAConsole.log -Force 2>&1 | Out-Null
Copy-Item "$($env:windir)\certocm.log" -Destination $_CERT_LOG_DIR\ADCS-InstallConfig.log -Force 2>&1 | Out-Null
Copy-Item "$($env:windir)\certsrv.log" -Destination $_CERT_LOG_DIR\ADCS-Debug.log -Force 2>&1 | Out-Null
Copy-Item "$($env:windir)\CertUtil.log" -Destination $_CERT_LOG_DIR\CertEnroll-Certutil.log -Force 2>&1 | Out-Null
Copy-Item "$($env:windir)\certreq.log" -Destination $_CERT_LOG_DIR\CertEnroll-Certreq.log -Force 2>&1 | Out-Null

Copy-Item "$($env:userprofile)\CertEnroll.log" -Destination $_CERT_LOG_DIR\CertEnroll-fromUserProfile.log -Force 2>&1 | Out-Null
Copy-Item "$($env:LocalAppData)\CertEnroll.log" -Destination $_CERT_LOG_DIRCertEnroll\CertEnroll-fromLocalAppData.log -Force 2>&1 | Out-Null

Add-Content -Path $_LOG_DIR\Schtasks.query.v.txt -Value (schtasks.exe /query /v 2>&1) | Out-Null
Add-Content -Path $_LOG_DIR\Schtasks.query.xml.txt -Value (schtasks.exe /query /xml 2>&1) | Out-Null

Write-Host "`nCollecting Device enrollment information, please wait....`n"

# **SCCM**
$_SCCM_DIR = "$($env:windir)\CCM\Logs"
If (Test-Path $_SCCM_DIR) {
    Copy-Item $_SCCM_DIR\CertEnrollAgent*.log -Destination $_SCCM_LOG_DIR -Force 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\StateMessage*.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\DCMAgent*.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\ClientLocation*.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\CcmEval*.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\CcmRepair*.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\PolicyAgent.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\CIDownloader.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\PolicyEvaluator.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\DcmWmiProvider*.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\CIAgent*.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\CcmMessaging.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\ClientIDManagerStartup.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
    Copy-Item $_SCCM_DIR\LocationServices.log -Destination $_SCCM_LOG_DIR 2>&1 | Out-Null
}

$_SCCM_DIR_Setup = "$($env:windir)\CCMSetup\Logs"
If (Test-Path $_SCCM_DIR_Setup) {
    Copy-Item $_SCCM_DIR_Setup\ccmsetup.log -Destination $_SCCM_LOG_DIR -Force 2>&1 | Out-Null
}

# ***MDM***
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\Enrollments" /s > $_MDM_LOG_DIR\MDMEnrollments-key.txt 2>&1 | Out-Null
reg query "HKEY_LOCAL_MACHINE\Software\Microsoft\EnterpriseResourceManager" /s > $_MDM_LOG_DIR\MDMEnterpriseResourceManager-key.txt 2>&1 | Out-Null
reg query "HKEY_CURRENT_USER\Software\Microsoft\SCEP" /s > $_MDM_LOG_DIR\MDMSCEP-User-key.txt 2>&1 | Out-Null
reg query "HKEY_CURRENT_USER\S-1-5-18\Software\Microsoft\SCEP" /s > $_MDM_LOG_DIR\MDMSCEP-SystemUser-key.txt 2>&1 | Out-Null

wevtutil query-events Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin /format:text > $_MDM_LOG_DIR\DmEventLog.txt 2>&1 | Out-Null

#DmEventLog.txt and Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider-Admin.txt might contain the same content
$DiagProvierEntries = wevtutil el
foreach ($DiagProvierEntry in $DiagProvierEntries) {
    $tempProvider = $DiagProvierEntry.Split('/')
    if ($tempProvider[0] -eq "Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider") {
        wevtutil qe $($DiagProvierEntry) /f:text /l:en-us > "$_MDM_LOG_DIR\$($tempProvider[0])-$($tempProvider[1]).txt"   2>&1 | Out-Null
    }
}

Write-Host "`nCollecting Device configuration information, please wait....`n"


Add-Content -Path $_LOG_DIR\Services-config.txt -Value (sc.exe query 2>&1) | Out-Null
Add-Content -Path $_LOG_DIR\Services-started.txt -Value (net start 2>&1) | Out-Null
Add-Content -Path $_LOG_DIR\FilterManager.txt -Value (fltmc 2>&1) | Out-Null
Gpresult /h $_LOG_DIR\GPOresult.html 2>&1 | Out-Null

(Get-ChildItem env:*).GetEnumerator() | Sort-Object Name | Out-File -FilePath $_LOG_DIR\Env.txt | Out-Null

$env:COMPUTERNAME + " " + $ProductName + " " + $InstallationType + " Version:" + $CurrentVersion + " " + $DisplayVersion + " Build:" + $CurrentBuildHex + "." + $UBRHEX | Out-File -Append $_LOG_DIR\Build.txt
"BuildLabEx: " + $BuildLabEx | Out-File -Append $_LOG_DIR\Build.txt

$SystemFiles = @(
    "$($env:windir)\System32\kerberos.dll"
    "$($env:windir)\System32\lsasrv.dll"
    "$($env:windir)\System32\netlogon.dll"
    "$($env:windir)\System32\kdcsvc.dll"
    "$($env:windir)\System32\msv1_0.dll"
    "$($env:windir)\System32\schannel.dll"
    "$($env:windir)\System32\dpapisrv.dll"
    "$($env:windir)\System32\basecsp.dll"
    "$($env:windir)\System32\scksp.dll"
    "$($env:windir)\System32\bcrypt.dll"
    "$($env:windir)\System32\bcryptprimitives.dll"
    "$($env:windir)\System32\ncrypt.dll"
    "$($env:windir)\System32\ncryptprov.dll"
    "$($env:windir)\System32\cryptsp.dll"
    "$($env:windir)\System32\rsaenh.dll"
    "$($env:windir)\System32\Cryptdll.dll"
    "$($env:windir)\System32\cloudAP.dll"
)

ForEach ($File in $SystemFiles) {
    if (Test-Path $File -PathType leaf) {
        $FileVersionInfo = (get-Item $File).VersionInfo
        $FileVersionInfo.FileName + ",  " + $FileVersionInfo.FileVersion | Out-File -Append $_LOG_DIR\Build.txt
    }
}

# ***Hotfixes***
Get-WmiObject -Class "win32_quickfixengineering" | Select -Property Description, HotfixID, @{Name = "InstalledOn"; Expression = { ([DateTime]($_.InstalledOn)).ToLocalTime() } }, Caption | Out-File -Append $_LOG_DIR\Qfes_installed.txt

Add-Content -Path $_LOG_DIR\whoami.txt -Value (Whoami /all 2>&1) | Out-Null

Add-Content -Path $_LOG_DIR\script-info.txt -Value ("Data collection stopped on: " + (Get-Date -Format "yyyy/MM/dd HH:mm:ss"))

Remove-Item -Path $_LOG_DIR\started.txt -Force | Out-Null

Write-Host "`n
===== Microsoft CSS Authentication Scripts tracing stopped =====`n
The tracing has now stopped and data has been saved to the ""Authlogs"" sub-directory.
The ""Authlogs"" directory contents (including subdirectories) can be supplied to Microsoft CSS engineers for analysis.`n`n
======================= IMPORTANT NOTICE =======================`n
The authentication script is designed to collect information that will help Microsoft Customer Support Services (CSS) troubleshoot an issue you may be experiencing with Windows.
The collected data may contain Personally Identifiable Information (PII) and/or sensitive data, such as (but not limited to) IP addresses, Device names, and User names.`n
Once the tracing and data collection has completed, the script will save the data in a subdirectory from where this script is launched called ""Authlogs"".
The ""Authlogs"" directory and subdirectories will contain data collected by the Microsoft CSS Authentication scripts.
This folder and its contents are not automatically sent to Microsoft.
You can send this folder and its contents to Microsoft CSS using a secure file transfer tool - Please discuss this with your support professional and also any concerns you may have.`n"

# SIG # Begin signature block
# MIInygYJKoZIhvcNAQcCoIInuzCCJ7cCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCBIjn1qlQEj/24s
# AywBNTx5jFYRfUthMXcgV6CLGGEouqCCDYEwggX/MIID56ADAgECAhMzAAACzI61
# lqa90clOAAAAAALMMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjIwNTEyMjA0NjAxWhcNMjMwNTExMjA0NjAxWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCiTbHs68bADvNud97NzcdP0zh0mRr4VpDv68KobjQFybVAuVgiINf9aG2zQtWK
# No6+2X2Ix65KGcBXuZyEi0oBUAAGnIe5O5q/Y0Ij0WwDyMWaVad2Te4r1Eic3HWH
# UfiiNjF0ETHKg3qa7DCyUqwsR9q5SaXuHlYCwM+m59Nl3jKnYnKLLfzhl13wImV9
# DF8N76ANkRyK6BYoc9I6hHF2MCTQYWbQ4fXgzKhgzj4zeabWgfu+ZJCiFLkogvc0
# RVb0x3DtyxMbl/3e45Eu+sn/x6EVwbJZVvtQYcmdGF1yAYht+JnNmWwAxL8MgHMz
# xEcoY1Q1JtstiY3+u3ulGMvhAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUiLhHjTKWzIqVIp+sM2rOHH11rfQw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDcwNTI5MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAeA8D
# sOAHS53MTIHYu8bbXrO6yQtRD6JfyMWeXaLu3Nc8PDnFc1efYq/F3MGx/aiwNbcs
# J2MU7BKNWTP5JQVBA2GNIeR3mScXqnOsv1XqXPvZeISDVWLaBQzceItdIwgo6B13
# vxlkkSYMvB0Dr3Yw7/W9U4Wk5K/RDOnIGvmKqKi3AwyxlV1mpefy729FKaWT7edB
# d3I4+hldMY8sdfDPjWRtJzjMjXZs41OUOwtHccPazjjC7KndzvZHx/0VWL8n0NT/
# 404vftnXKifMZkS4p2sB3oK+6kCcsyWsgS/3eYGw1Fe4MOnin1RhgrW1rHPODJTG
# AUOmW4wc3Q6KKr2zve7sMDZe9tfylonPwhk971rX8qGw6LkrGFv31IJeJSe/aUbG
# dUDPkbrABbVvPElgoj5eP3REqx5jdfkQw7tOdWkhn0jDUh2uQen9Atj3RkJyHuR0
# GUsJVMWFJdkIO/gFwzoOGlHNsmxvpANV86/1qgb1oZXdrURpzJp53MsDaBY/pxOc
# J0Cvg6uWs3kQWgKk5aBzvsX95BzdItHTpVMtVPW4q41XEvbFmUP1n6oL5rdNdrTM
# j/HXMRk1KCksax1Vxo3qv+13cCsZAaQNaIAvt5LvkshZkDZIP//0Hnq7NnWeYR3z
# 4oFiw9N2n3bb9baQWuWPswG0Dq9YT9kb+Cs4qIIwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZnzCCGZsCAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAsyOtZamvdHJTgAAAAACzDAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg5JUJ2vFN
# jMnKY/25SE1d8JbzVF1PMdqlzx8U3/nmSW0wQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQBHr9IYzvsXzAFHg4Z5isbgn+MAnuKReaYu+YYjHTHB
# abktjEd9qslfJA/cq/TEH0khPz0k9G9dAZhTUjICsn0jdu4bdH/ng1UROzU3BHDg
# 0VhZMqbl1BEgAhlWEuFF0q3XsHQYaiwSvCweOurjiqXZAZ7OZd6lIALgr8OV5Gnf
# UiO5+BJ2+NE3Fm/tA6eCv8RcKjCiMTl+SB1hM9jjlHwqHXuVYFMbkGKrN2Xl1NoF
# sSA73xRRIeUCjE4JKVyogrBL61Kx8wxFt2UHpcYfcUZghYxn540ImGGpiFdJPIOB
# 2r86Zmuuzm5E+XGef/yAiOw4InpkxdpmsZSAvEZxCqJnoYIXKTCCFyUGCisGAQQB
# gjcDAwExghcVMIIXEQYJKoZIhvcNAQcCoIIXAjCCFv4CAQMxDzANBglghkgBZQME
# AgEFADCCAVkGCyqGSIb3DQEJEAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIPHluSQ/UkBsGhecozL/hridYinUHzhwLDDxWbvx
# Z4YAAgZjN1NvQ8YYEzIwMjIxMDE3MTAwMDM0LjQ2N1owBIACAfSggdikgdUwgdIx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
# Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhh
# bGVzIFRTUyBFU046MTc5RS00QkIwLTgyNDYxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2WgghF4MIIHJzCCBQ+gAwIBAgITMwAAAbWtGt/XhXBt
# EwABAAABtTANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMDAeFw0yMjA5MjAyMDIyMTFaFw0yMzEyMTQyMDIyMTFaMIHSMQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQg
# SXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
# RVNOOjE3OUUtNEJCMC04MjQ2MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBTZXJ2aWNlMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAlwsKuGVe
# gsKNiYXFwU+CSHnt2a7PfWw2yPwiW+YRlEJsH3ibFIiPfk/yblMp8JGantu+7Di/
# +3e5wWN/nbJUIMUjEWJnc8JMjoPmHCWsMtJOuR/1Ru4aa1RrxQtIelq098TBl4k7
# NsEE87l7qKFmy8iwGNQjkwr0bMu4BJwy7BUXiXHegOSU992rfQ4xNZoxznv42TLQ
# sc9NmcBq5WslkqVATcc8PSfgBLEpdG1Dp2wqNw4JrJFwJNA1bfzTScYABc5smRZB
# gsP4JiK/8CVrlocheEyQonjm3rFttrojAreSUnixALu9pDrsBI4DUPGG34oIbieI
# 1oqFl/xk7A+7uM8k4o8ifMVWNTaczbPldDYtn6hBre7r25RED4uecCxP8Dxy34YP
# UElWllPP3LAXp5cMwRjx+EWzjEtILEKXuAcfxrXCTwyYhm5XNzCCZYh4/gF2U2y/
# bYfekKpaoFYwkoZeT6ZxoQbX5Kftgj+tZkFV21UvZIkJ6b34a/44dtrsK6diTmVn
# NTM9J6P6Ehlk2sfcUwbHIGL8mYqdKOiyd4RxOCmSvcFNkZEgrk548mHCbDbTyO9x
# SzN1EkWxbp8n/LHVnZ9fp5hILGntkMzaD5aXRCQyHSIhsPtR7Q/rKoHyjFqgtGO9
# ftnxYvxzNrbKeMCzwmcqwMrX6Hcxe0SeKZ8CAwEAAaOCAUkwggFFMB0GA1UdDgQW
# BBRsUIbZgoZVXVXVWQX0Ok1VO2bHUzAfBgNVHSMEGDAWgBSfpxVdAF5iXYP05dJl
# pxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQhk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBUaW1lLVN0YW1wJTIwUENBJTIwMjAx
# MCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBeMFwGCCsGAQUFBzAChlBodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFRpbWUtU3Rh
# bXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQM
# MAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAgEA
# kFGOpyjKV2s2sA+wTqDwDdhp0mFrPtiU4rN3OonTWqb85M6WH19c/P517xujLCih
# /HllP5xKWmXnAIRV1/NQDkJBLSdLTb/NQtcT1FWGQ7CMTnrn9tLZxqIFtKVylvQN
# yh31C/qkC8QmNpyzakO0G38uOGgOkJ9Eq4nA+7QwVfobDlggWuEpzdFnRdyXL32g
# OqSvrLjFKpv4KEVqaBTiaxCWZDlIhG3YgUza7cnG5Z2SA/feMq/IiV06AzUadZw6
# XgcTrqXmEmE0tMmdl44MMFC3wGU9AVeFCWKdD9WOnYA2zHg+XF2LQVto0VYtFLd6
# c6DQFcmB38GvPCKVYSn8r10EoXuRN+gQ7hLcim12esOnW4F4bHCmHWTVWeAGgPiS
# ItHHRfGKLEUZmotVOdFPR8wiuADT/fHSXBkkdpL12tvgEGELeTznzFulZ16b/Nv6
# dtbgSRZreesJBNKpTjdYju/GqnlAkpflL6J0wxk957/UVYnmjjRY61jX90QGQmBz
# m9vs/+2bj02Xx/bXXy8vq57jmNXQ2ufOaJm3nAcD2qOaSyXEOj9mqhMt4tdvMjHh
# iNPldfj0Q7Kq1HgdRBrKWkzCQNi4ts8HRJBipNaVpWfU7BcRn8BeYzdLoIzwRLDt
# atz6aBho3oD/bXHrZagxprM5MsMB/rVfb5Xn1YS7/uEwggdxMIIFWaADAgECAhMz
# AAAAFcXna54Cm0mZAAAAAAAVMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9v
# dCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0yMTA5MzAxODIyMjVaFw0z
# MDA5MzAxODMyMjVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMIICIjAN
# BgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA5OGmTOe0ciELeaLL1yR5vQ7VgtP9
# 7pwHB9KpbE51yMo1V/YBf2xK4OK9uT4XYDP/XE/HZveVU3Fa4n5KWv64NmeFRiMM
# tY0Tz3cywBAY6GB9alKDRLemjkZrBxTzxXb1hlDcwUTIcVxRMTegCjhuje3XD9gm
# U3w5YQJ6xKr9cmmvHaus9ja+NSZk2pg7uhp7M62AW36MEBydUv626GIl3GoPz130
# /o5Tz9bshVZN7928jaTjkY+yOSxRnOlwaQ3KNi1wjjHINSi947SHJMPgyY9+tVSP
# 3PoFVZhtaDuaRr3tpK56KTesy+uDRedGbsoy1cCGMFxPLOJiss254o2I5JasAUq7
# vnGpF1tnYN74kpEeHT39IM9zfUGaRnXNxF803RKJ1v2lIH1+/NmeRd+2ci/bfV+A
# utuqfjbsNkz2K26oElHovwUDo9Fzpk03dJQcNIIP8BDyt0cY7afomXw/TNuvXsLz
# 1dhzPUNOwTM5TI4CvEJoLhDqhFFG4tG9ahhaYQFzymeiXtcodgLiMxhy16cg8ML6
# EgrXY28MyTZki1ugpoMhXV8wdJGUlNi5UPkLiWHzNgY1GIRH29wb0f2y1BzFa/Zc
# UlFdEtsluq9QBXpsxREdcu+N+VLEhReTwDwV2xo3xwgVGD94q0W29R6HXtqPnhZy
# acaue7e3PmriLq0CAwEAAaOCAd0wggHZMBIGCSsGAQQBgjcVAQQFAgMBAAEwIwYJ
# KwYBBAGCNxUCBBYEFCqnUv5kxJq+gpE8RjUpzxD/LwTuMB0GA1UdDgQWBBSfpxVd
# AF5iXYP05dJlpxtTNRnpcjBcBgNVHSAEVTBTMFEGDCsGAQQBgjdMg30BATBBMD8G
# CCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL0RvY3Mv
# UmVwb3NpdG9yeS5odG0wEwYDVR0lBAwwCgYIKwYBBQUHAwgwGQYJKwYBBAGCNxQC
# BAweCgBTAHUAYgBDAEEwCwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHwYD
# VR0jBBgwFoAU1fZWy4/oolxiaNE9lJBb186aGMQwVgYDVR0fBE8wTTBLoEmgR4ZF
# aHR0cDovL2NybC5taWNyb3NvZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvTWljUm9v
# Q2VyQXV0XzIwMTAtMDYtMjMuY3JsMFoGCCsGAQUFBwEBBE4wTDBKBggrBgEFBQcw
# AoY+aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJB
# dXRfMjAxMC0wNi0yMy5jcnQwDQYJKoZIhvcNAQELBQADggIBAJ1VffwqreEsH2cB
# MSRb4Z5yS/ypb+pcFLY+TkdkeLEGk5c9MTO1OdfCcTY/2mRsfNB1OW27DzHkwo/7
# bNGhlBgi7ulmZzpTTd2YurYeeNg2LpypglYAA7AFvonoaeC6Ce5732pvvinLbtg/
# SHUB2RjebYIM9W0jVOR4U3UkV7ndn/OOPcbzaN9l9qRWqveVtihVJ9AkvUCgvxm2
# EhIRXT0n4ECWOKz3+SmJw7wXsFSFQrP8DJ6LGYnn8AtqgcKBGUIZUnWKNsIdw2Fz
# Lixre24/LAl4FOmRsqlb30mjdAy87JGA0j3mSj5mO0+7hvoyGtmW9I/2kQH2zsZ0
# /fZMcm8Qq3UwxTSwethQ/gpY3UA8x1RtnWN0SCyxTkctwRQEcb9k+SS+c23Kjgm9
# swFXSVRk2XPXfx5bRAGOWhmRaw2fpCjcZxkoJLo4S5pu+yFUa2pFEUep8beuyOiJ
# Xk+d0tBMdrVXVAmxaQFEfnyhYWxz/gq77EFmPWn9y8FBSX5+k77L+DvktxW/tM4+
# pTFRhLy/AsGConsXHRWJjXD+57XQKBqJC4822rpM+Zv/Cuk0+CQ1ZyvgDbjmjJnW
# 4SLq8CdCPSWU5nR0W2rRnj7tfqAxM328y+l7vzhwRNGQ8cirOoo6CGJ/2XBjU02N
# 7oJtpQUQwXEGahC0HVUzWLOhcGbyoYIC1DCCAj0CAQEwggEAoYHYpIHVMIHSMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNy
# b3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxl
# cyBUU1MgRVNOOjE3OUUtNEJCMC04MjQ2MSUwIwYDVQQDExxNaWNyb3NvZnQgVGlt
# ZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQCNMJ9r11RZj0PWu3uk+aQH
# F3IsVaCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9u
# MRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
# b24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqG
# SIb3DQEBBQUAAgUA5veSCzAiGA8yMDIyMTAxNzE2MzQxOVoYDzIwMjIxMDE4MTYz
# NDE5WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDm95ILAgEAMAcCAQACAgC6MAcC
# AQACAhCLMAoCBQDm+OOLAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkK
# AwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQEFBQADgYEAjFCc
# rYxTXsp7uTHpU5WPa2Vb/SUC0RGL230sYCW/KOZTG+nD2WEu0sUEKjb+JA4UdZfU
# FQkqgGa8Ksd4M1wc3PHzW/Wo/6+/Ok56waMhy/1x7luIvJ6Oi0TCRuTmLItB7heN
# /nQ6hDh/qO3i5vNlu2QrbelU9Z3pAhwqx5AwimAxggQNMIIECQIBATCBkzB8MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNy
# b3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAbWtGt/XhXBtEwABAAABtTAN
# BglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8G
# CSqGSIb3DQEJBDEiBCBxH5Kl46TP4ELBh2RTRc1NgiNS+1XeG3v41ozdv29M4TCB
# +gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EICfKDTUtaGcWifYc3OVnIpp7Ykn0
# S8JclVzrlAgF8ciDMIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldh
# c2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
# b3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIw
# MTACEzMAAAG1rRrf14VwbRMAAQAAAbUwIgQgDpHwOUvVrkE+ZXj0HVeJ1uEj4Rv5
# fAD5PxEnMLSbURAwDQYJKoZIhvcNAQELBQAEggIAYchAF7hjmp0bH9+I0ntSBq7I
# 0IIrcVaIKoBQ0uSBnaeXDiiudTL64ednlZFlogKqL2uxoi5aoI6EtUXmF6KPPMM/
# AleKZE6DOlW2Fz4l9kTmRe6TGwqgpbpyAmx+64KacsH12veFrnCSx14Qxp8wy0FQ
# nxLA7wVoEa8Uy83EGvnHT6L6257SzGF9vqkWqWIDkn/n/npnt8dL6VSLJOwaATqA
# 2W+pOPheJahtq+4cZC0kOtLucPS1O8gCMBCDtMyu6vxo3f9jys4fmZsICumquSrD
# uxq1ADiLFdpYH6MvX+2TqgG2K9NKLnq8XynV8m+yn8ziWuNder7rmihzWIM7EGID
# xDlG+pGdKFkWapao77KpYYd7r9uuOXFO/5g9qFJGMnKSPZy7fqeZY24h3bV5uTqf
# 5T7pGHXDp5LvuCb0mvxevw0oMRLSDTDf8NpNY0UQlD/fUcgj6exQEHXN3nbnEa/e
# 7MRxh8dbkHL12AwVBdFbqtHe9i+JtxbEItPv/3mVhEVmO2buHcuu07pIOOB8z0Lu
# vyPYYglOlzdYMVDxSEGBPjfV/kH7fgXmikIHcDlGvBk9HhcZmmIpxk2QQbIs3Ze+
# S3HhjLGhpnMxMfgSlg7CVDUGRPde+bJtd2m32CiANV+WUvKSoblJqvm428cv3HPS
# UqKBi73N9OiiF6us9qs=
# SIG # End signature block
