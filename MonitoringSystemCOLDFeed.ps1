#This script takes pdfs from patient monitoring system output directory, finds the test date/time from within the file, then names it appropriately for MEDITECH COLD feed format.
#Set working dir to PIIXStrips
Set-Location -Path "C:\Meditech\PIIXStrips"
#Moves pdfs from IBE01 to Local
Move-Item -Path "\\networkshare\IICIX\HIS share\*.pdf" -Destination "C:\Meditech\PIIXStrips\Working"
#Creates a copy of the file in the archive
Copy-Item "C:\Meditech\PIIXStrips\Working\*.*" -Destination "C:\Meditech\PIIXStrips\Archive"
#Creates list of pdfs in working dir
$pdfs = Get-ChildItem -Path "C:\Meditech\PIIXStrips\Working\*.pdf"
$pdftotext = "C:\Meditech\PIIXStrips\pdftotext.exe"

#This foreach statement creates a .txt version of each PDF for processing
ForEach ($pdf in $pdfs) {
    Start-Process $pdftotext -ArgumentList "$pdf"
    Start-Sleep -Milliseconds 15
    }
Start-Sleep -Seconds 5
#Creates list of TXTs in working dir
$files = Get-ChildItem -Path "C:\Meditech\PIIXStrips\Working\*.txt"
#Write-Host $files
ForEach ($file in $files) {
    
    #Finds line that starts with "Printed on"
	$txt = Select-String -Path $file -Pattern 'Printed on '
    #Write-Host $txt
    If ($txt) {
    $substr = $txt.Line.Split(' ')
    $fileName = $file.Name
    $fileNameShort = $fileName.SubString(0,$fileName.Length-4)
    $fileNamePDF = $fileNameShort + '.pdf'
    $ACC = $fileNameShort.SubString(0,12)
	#Write-Host $fileNameShort
    $datestr = $substr[2].Split('/')
    #Write-Host $datestr
    if ($datestr[0].Length -eq 1) {
        $date0 = $datestr[0]
        $mm = "0$date0"
        } else {
        $mm = $datestr[0]
    }
    if ($datestr[1].Length -eq 1) {
        $date1 = $datestr[1]
        $dd = "0$date1"
        } else {
        $dd = $datestr[1]
    }
	$yy = $datestr[2]
    $date = "$yy$mm$dd"
    #Write-Host $date
    $timestr = $substr[3].Split(':')
    #Write-Host $timestr
    $hh = $timestr[0]
    $mn = $timestr[1]
    $ss = $timestr[2]
    $tm = "$hh$mn"
    #Write-Host $tm
    Copy-Item "C:\Meditech\PIIXStrips\Working\$fileNamePDF" -Destination "C:\Meditech\PIIXStrips\Outbound"
    $time = Get-Date -UFormat "%m%d%Y %H%M%S"
    #Write-Host $time
    Rename-Item "C:\Meditech\PIIXStrips\Outbound\$fileNamePDF" -NewName "$time$ss             $ACC          TELESTRIPS                    $date$tm.pdf"
    }
    Start-Sleep -Seconds 1
}
Remove-Item "C:\Meditech\PIIXStrips\Working\*.*"
