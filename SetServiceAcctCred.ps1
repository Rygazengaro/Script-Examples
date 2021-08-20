#This script loops through all MEDITECH servers from csv and updates the services listed with the new service password and restarts them.
Function Set-ServiceAcctCreds([string]$strCompName,[string]$strServiceName,[string]$newAcct,[string]$newPass){
  $filter = 'Name=' + "'" + $strServiceName + "'" + ''
  $service = Get-WMIObject -ComputerName $strCompName -namespace "root\cimv2" -class Win32_Service -Filter $filter
  $service.Change($null,$null,$null,$null,$null,$null,$newAcct,$newPass)
  $service.StopService()
  while ($service.Started){
    sleep 2
    $service = Get-WMIObject -ComputerName $strCompName -namespace "root\cimv2" -class Win32_Service -Filter $filter
  }
  $service.StartService()
}

$Acct = "domain\username"
$PassSec = Read-Host "Enter password" -AsSecureString
$PassCon = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($PassSec)
$Pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($PassCon)
$svcarray = "B20180413051905321_TEST_Outbound", "B20180413051905321_TEST_Inbound", "VMagicPPII", "MaestroAppService-TEST", "MaestroAppService-LIVE", "MEDITECH CSProxy Server", "MEDITECH CS Bkg Jobs", "MEDITECH UNV Daemon (KRE)"
$srvarray = Import-Csv -Path C:\serverlist.csv -Header A | Select-Object -Unique A

ForEach ($srv in $srvarray) {
    $CompName = $srv.A
    ForEach ($svc in $svcarray) {
        $ServiceName = $svc
        Set-ServiceAcctCreds -strCompName $CompName -strServiceName $ServiceName -newAcct $Acct -newPass $Pass
    }
}


