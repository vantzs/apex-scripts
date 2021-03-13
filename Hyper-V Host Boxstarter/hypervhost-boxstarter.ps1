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

# Windows Components
choco install Microsoft-Hyper-V-All -source windowsFeatures

if (Test-PendingReboot) { Invoke-Reboot }

# Install Chocolatey and Basic Software
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
$Packages = 'googlechrome', 'firefoxesr', 'dell-omsa', 'dellcommandupdate'
ForEach ($PackageName in $Packages)
{
    choco install $PackageName -y
}

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
New-NetLbfoTeam -Name "Converged Local Area Network Connection Team" -TeamMembers "Converged Local Area Network Connection 1","Converged Local Area Network Connection 2"
New-VMSwitch -name "Converged Local Area Network Connection Team - Virtual Network" -NetAdapterName "Converged Local Area Network Connection Team" -AllowManagementOs $true
New-Item -Path D:\ -Name Hyper-V -ItemType Directory
Set-VMHost -VirtualMachinePath 'D:\Hyper-V'