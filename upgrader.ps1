# Check for admin rights
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run the script as an administrator!"
    pause
    exit
}

# Prepare the environment (ensure that TLS 1.2 is used for downloads)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy RemoteSigned -Force -Scope CurrentUser

# Load module (and install if missing)
if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "Install required module..." -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
    Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Confirm:$false -Scope CurrentUser
}

# 1. Software updates via Winget
Write-Host "--- Search for software updates (Winget) ---" -ForegroundColor Cyan
winget upgrade --all --accept-package-agreements --accept-source-agreements --silent

# 2. Driver & system updates via Windows Update
Write-Host "--- Searching for drivers & system updates ---" -ForegroundColor Cyan
Import-Module PSWindowsUpdate
Get-WindowsUpdate -Install -AcceptAll -MicrosoftUpdate -Verbose -IgnoreReboot

Write-Host "Done! Your system is up to date." -ForegroundColor Green

# Open a graphical window (MessageBox)
$title = "Restart required"
$message = "The updates have been installed. Would you like to restart your computer now?"
$options = [System.Windows.MessageBoxButton]::YesNo
$icon = [System.Windows.MessageBoxImage]::Question

# Ensure that the graphics class is loaded
Add-Type -AssemblyName PresentationFramework

$response = [System.Windows.MessageBox]::Show($message, $title, $options, $icon)

if ($response -eq "Yes") {
    Write-Host "Restart..." -ForegroundColor Red
    Restart-Computer
} else {
    Write-Host "Restart canceled. Please remember to restart manually later." -ForegroundColor Yellow
    pause
}
