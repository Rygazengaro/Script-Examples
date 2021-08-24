#This script completely configures VMWare Horizon Client and SSO client in Kiosk mode on Machine.
#Variables for 64-bit vs 32-bit OS
if ([System.IntPtr]::Size -eq 4) {$imp = "C:\Program Files\Imprivata\OneSign Agent\"} else {$imp = "C:\Program Files (x86)\Imprivata\OneSign Agent\"} 
if ([System.IntPtr]::Size -eq 4) {$impinstall = "\\networkshare\Programs\SSO\Support Tools\ImprivataAgent.msi"} else {$impinstall = "\\networkshare\Programs\SSO\Support Tools\ImprivataAgent_x64.msi"} 

#Variables
$msi = "/i $impinstall IACCEPTSQLNCLILICENSETERMS=YES IPTXPRIMSERVER=https://serveraddress/sso/servlet/messagerouter AGENTTYPE=2"

#Copies files and startup scripts
copy "\\networkshare\Programs\SSO\Support Tools\killexplorer.bat" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
Copy-Item "\\networkshare\Programs\SSO\Support Tools\Horizon GP Addon\*" "C:\Windows\PolicyDefinitions\" -Recurse

#Import Reg Keys for AutoLogin and VMware local policies
reg import "\\networkshare\Programs\SSO\Support Tools\ER\VMWAREPolicies.reg"
reg import "\\networkshare\programs\SSO\Support Tools\ER\WinLogon.reg"

#Installation of VMware Client
$vars = "/silent /norestart VDM_SERVER=horizon.networkserver.org LOGINASCURRENTUSER_DISPLAY=0 LOGINASCURRENTUSER_DEFAULT=0"
$vm = "\\networkshare\Programs\SSO\Mobile Carts and VM Kiosks\VMware-Horizon-Client-5.4.2-15936851.exe"
New-Item -ItemType directory -Path C:\VM_TEMP | Out-Null
copy $vm C:\VM_TEMP\
$localfile = Get-ChildItem C:\VM_TEMP\*.exe
write-host "Installing VMWare Horizon Client..."
Start-Process $localfile -ArgumentList $vars -Wait
Start-Sleep -Seconds 2
Write-Host "Installation Complete, cleaning up temp directory"
Remove-Item C:\VM_Temp -Force -Recurse | Out-Null
Start-Sleep -Seconds 5
Write-Host "VMWare Horizon Client installation is complete."

#Installation of SSO Kiosk Agent
if ([System.IntPtr]::Size -eq 4) {
    #32bit
    Write-Host "Installing Imprivata Kiosk Agent"
    reg.exe import "\\networkshare\Programs\SSO\Support Tools\x86_Kiosk.reg"
    Start-Process msiexec -ArgumentList $msi -Wait
    Start-Sleep -Seconds 2
    Write-Host "Imprivata Kiosk Agent installation is complete."
}    else {
      #64bit
      Write-Host "Installing Imprivata Kiosk Agent"
      reg.exe import "\\networkshare\Programs\SSO\Support Tools\x64_Kiosk.reg"
      Start-Process msiexec -ArgumentList $msi -Wait
      Start-Sleep -Seconds 2
      Write-Host "Imprivata Kiosk Agent installation is complete."
}
reg import "\\networkshare\programs\SSO\Support Tools\ER\WinLogon.reg"
