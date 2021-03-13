# Hyper-V Host Auto Build
# Apex Technology
# 3/13/2021 Vantz Stockwell

$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

# Basic Windows Settings
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
Enable-RemoteDesktop
Update-ExecutionPolicy RemoteSigned
Disable-InternetExplorerESC
Enable-MicrosoftUpdate

# Setting Time Zone
Write-BoxstarterMessage "Setting time zone to Eastern Standard Time"
& C:\Windows\system32\tzutil /s "Eastern Standard Time"

# Set Windows power options
Write-BoxstarterMessage "Setting Standby Timeout to Never"
powercfg -change -standby-timeout-ac 0
powercfg -change -standby-timeout-dc 0

Write-BoxstarterMessage "Turning off Windows Hibernation"
powercfg -h off
 
Write-BoxstarterMessage "Setting Monitor Timeout to 20 minutes"
powercfg -change -monitor-timeout-ac 20
powercfg -change -monitor-timeout-dc 20
 
Write-BoxstarterMessage "Setting Disk Timeout to Never"
powercfg -change -disk-timeout-ac 0
powercfg -change -disk-timeout-dc 0

# Install required PS Gallery Script Test-PendingReboot
Install-PackageProvider -Name NuGet -Force
Install-Script -Name Test-PendingReboot -Force

if (Test-PendingReboot) { Invoke-Reboot }