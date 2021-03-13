# Hyper-V Host Auto Build
# Apex Technology
# 3/13/2021 Vantz Stockwell

$Boxstarter.RebootOk=$true # Allow reboots?
$Boxstarter.NoPassword=$false # Is this a machine with no login password?
$Boxstarter.AutoLogin=$true # Save my password securely and auto-login after a reboot

# Basic Windows Settings
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

# Boxstarter Requirements
cinst boxstarter.common -y --force
cinst boxstarter.winconfig -y --force
cinst boxstarter.Bootstrapper -y --force
cinst boxstarter.Chocolatey -y --force
cinst boxstarter.HyperV -y --force

# Install Hyper-V Role
Install-WindowsFeature -name hyper-v -IncludeManagementTools

if (Test-PendingReboot) { Invoke-Reboot }

# Install Basic Server Software
cinst firefoxesr -y

if (Test-PendingReboot) { Invoke-Reboot }

# Windows Updates
Install-WindowsUpdate -AcceptEula

if (Test-PendingReboot) { Invoke-Reboot }

# Rename Computer and Set Timezon
#--- Rename the Computer ---
$computername = "LI-HyperV01"
if ($env:computername -ne $computername) {
	Rename-Computer -NewName $computername
}

if (Test-PendingReboot) { Invoke-Reboot }

Rename-NetAdapter -Name "NIC1" -NewName "Converged Local Area Network Connection 1"
Rename-NetAdapter -Name "NIC2" -NewName "Converged Local Area Network Connection 2"
New-NetLbfoTeam -Name "Converged Local Area Network Connection Team" -TeamMembers "Converged Local Area Network Connection 1","Converged Local Area Network Connection 2" -y
Get-NetAdapter teama | Set-DnsClientServerAddress -ServerAddresses New-VMSwitch -name "Converged Local Area Network Connection Team - Virtual Network" -NetAdapterName "Converged Local Area Network Connection Team" -AllowManagementOs $true
Get-NetAdapter teama | Set-DnsClientServerAddress -ServerAddresses '1.1.1.1','1.0.0.1'
New-Item -Path D:\ -Name Hyper-V -ItemType Directory
Set-VMHost -VirtualMachinePath 'D:\Hyper-V'
New-Item -Path C:\ -Name Temp -ItemType Directory	
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("https://carolinashost.com/Systems-Management_Application_8CTK7_WN64_1.9.0_A00.EXE","C:\temp\Systems-Management_Application_8CTK7_WN64_1.9.0_A00.EXE")
$pathvargs = {C:\temp\Systems-Management_Application_8CTK7_WN64_1.9.0_A00.EXE /S /v/qn }
Invoke-Command -ScriptBlock $pathvargs
Invoke-Reboot
& 'C:\Program Files\Dell\DELL EMC system Update\DSU' @('--apply-upgrades', '--non-interactive', '--reboot')