#This script functions to loop through all servers on the domain and remove Trend Anti-virus and replace with Crowdstrike
$list = Import-CSV -Path "C:\temp\serverlist.csv"
$scutparam = "-noinstall"
$csparam = "/install /quiet /norestart"
$list | ForEach-Object {
    $hostn = $_.hostname
    Write-Host $hostn
    $Sess = New-PSSession -Computername $hostn
    Copy-Item -Path "\\networkshare\temp\a1\*" -Destination "\\$hostn\c$" -Recurse
    Copy-Item -Path "\\networkshare\programs\crowdstrike\WindowsSensor.exe" -Destination "\\$hostn\c$"
    Invoke-Command -Session $Sess -Scriptblock {Start-Process -FilePath "C:\windowssensor.exe" -ArgumentList "/install /quiet /norestart" -Wait}    
    Invoke-Command -Session $Sess -Scriptblock {Start-Process -FilePath "C:\scut.exe" -ArgumentList "-noinstall" -Wait}
    Remove-Item -Path "\\$hostn\c$\WindowsSensor.exe"
    Remove-Item -Path "\\$hostn\c$\scut.exe"
    Remove-Item -Path "\\$hostn\c$\scut.exe.config"
	$Sess | Remove-PSSession
}