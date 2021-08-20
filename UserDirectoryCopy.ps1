#This script checks for user's current location and moves those directories to new storage for group-policy profile redirection
#FUNCTION FOR REGPATH
function Test-RegistryValue {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Path,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Value
    )
    try {
        Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

$user = $env:UserName
#Copies users files from their current mapped directories to new structure
    If (Test-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Value Desktop) {
        $UserDesktop = (Get-ItemProperty ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders")) | Select-Object -ExpandProperty Desktop
       # Copy-Item -Path $UserDesktop\* -Destination \\networkshare\profiles'\$'\$user\Desktop -Recurse
        ROBOCOPY "$UserDesktop" "\\networkshare\profiles`$\$user\Desktop" /XO /E /XJD
        }
    If (Test-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Value Favorites) {
        $UserFavorites = (Get-ItemProperty ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders")) | Select-Object -ExpandProperty Favorites
       # Copy-Item -Path $UserFavorites\* -Destination \\networkshare\profiles'\$'\$user\Favorites -Recurse
        ROBOCOPY "$UserFavorites" "\\networkshare\profiles`$\$user\Favorites" /XO /E /XJD
    }
    If (Test-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Value "My Pictures") {
        $UserPictures = (Get-ItemProperty ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders")) | Select-Object -ExpandProperty "My Pictures"
       # Copy-Item -Path $UserPictures\* -Destination "\\networkshare\profiles'\$'\$user\Documents\My Pictures" -Recurse
        ROBOCOPY "$UserPictures" "\\networkshare\profiles`$\$user\Documents\My Pictures" /XO /E /XJD
    }
    If (Test-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -Value Personal) {
        $UserDocuments = (Get-ItemProperty ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders")) | Select-Object -ExpandProperty Personal
       # Copy-Item -Path $UserDocuments\* -Destination \\networkshare\profiles'\$'\$user\Documents -Recurse
        ROBOCOPY "$UserDocuments" "\\networkshare\profiles`$\$user\Documents" /XO /E /XJD
    }