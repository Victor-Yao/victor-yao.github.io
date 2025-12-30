@echo off
setlocal

REM export to CurrentPath\reports
set "DIRECTORY=%~dp0reports"

if not exist "%DIRECTORY%" (
    mkdir "%DIRECTORY%"
)

reg query "HKLM\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL" /s > "%DIRECTORY%\%COMPUTERNAME%_ssl1.txt"
reg query "HKLM\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL" /s > "%DIRECTORY%\%COMPUTERNAME%_ssl2.txt"
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL" /s > "%DIRECTORY%\%COMPUTERNAME%_ssl3.txt"
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA\FIPSAlgorithmPolicy" /s > "%DIRECTORY%\%COMPUTERNAME%_ssl4.txt"

echo reports exported successfully!
endlocal
