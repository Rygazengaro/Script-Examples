#This script takes pdfs from Tracemaster output directory, finds the test date/time from within the file, then names it appropriately for MEDITECH COLD feed format.
#Set working dir to ECG
Set-Location -Path "C:\Meditech\ECG"
#Move files from inbound folder to working dir
Move-Item -Path "C:\Meditech\ECG\ECGInbound\*.pdf" -Destination "C:\Meditech\ECG\Working"
#Make a copy of the files to archive
Copy-Item "C:\Meditech\ECG\Working\*.*" -Destination "C:\Meditech\ECG\Archive"
#Create list of PDFs to work with
$pdfs = Get-ChildItem -Path "C:\Meditech\ECG\Working\*.pdf"
$pdftotext = "C:\Meditech\ECG\pdftotext.exe"
#Loop through each PDF and process
ForEach ($pdf in $pdfs) {
    Start-Process $pdftotext -ArgumentList $pdf
    Start-Sleep -Milliseconds 15
    }
Start-Sleep -Seconds 5
$files = Get-ChildItem -Path "C:\Meditech\ECG\Working\*.txt"
#Write-Host $files
ForEach ($file in $files) {
    
    #\d is numeric wildcard, . is wildcard this is to filter the PDF for lines that contain dates
	$txt = Select-String -Path $file -Pattern '\d\d-...-\d'
    #Write-Host $txt
    If ($txt) {
    $substr = $txt.Line
    $i = 0
    
	#This foreach loop is to count total substrings
	ForEach ($sstr in $substr) {
    $i++
    }
	#This variable allows $lasti to pull the final substring in the array
    $lasti = $i - 1
    #Write-Host $substr[$lasti]
	#datestr splits substrings into further substrings by -
    $datestr = $substr[$lasti].Split('-')
    #Write-Host $datestr
    #if statement prevents single digit numeric date value from being used.. Ex. 1 becomes 01
	if ($datestr[0].Length -eq 1) {
        $date0 = $datestr[0]
        $dd = "0$date0"
        } else {
        $dd = $datestr[0]
    }
    #converts 3 character month to 2 digit numeric value
	if ($datestr[1] -match "jan") {
        $mm = "01"
        } elseif ($datestr[1] -match "feb") {
        $mm = "02"
        } elseif ($datestr[1] -match "mar") {
        $mm = "03"
        } elseif ($datestr[1] -match "apr") {
        $mm = "04"
        } elseif ($datestr[1] -match "may") {
        $mm = "05"
        } elseif ($datestr[1] -match "jun") {
        $mm = "06"
        } elseif ($datestr[1] -match "jul") {
        $mm = "07"
        } elseif ($datestr[1] -match "aug") {
        $mm = "08"
        } elseif ($datestr[1] -match "sep") {
        $mm = "09"
        } elseif ($datestr[1] -match "oct") {
        $mm = "10"
        } elseif ($datestr[1] -match "nov") {
        $mm = "11"
        } elseif ($datestr[1] -match "dec") {
        $mm = "12"
    }
	$yy = $datestr[2].SubString(0,4)
    $date = "$yy$mm$dd"
    #Write-Host $date
    #timestr splits substring into further substrings by :
	$timestr = $substr[$lasti].Split(':')
    #Write-Host $timestr
	$hh = $timestr[0].SubString($timestr[0].Length - 2,2)
    $mn = $timestr[1]
    $ss = $timestr[2]
    $tm = "$hh$mn"
    #Write-Host $tm
    $fileName = $file.Name
    $fileNameShort = $fileName.SubString(0,$fileName.Length-4)
    $fileNamePDF = $fileNameShort + '.pdf'
    #account number is always first 12 characters of the file name
	$ACC = $fileNameShort.SubString(0,12)
    Copy-Item "C:\Meditech\ECG\Working\$fileNamePDF" -Destination "C:\Meditech\ECG\Outbound"
    $time = Get-Date -UFormat "%m%d%Y %H%M%S"
    #Write-Host $time
    #Renames file to cold feed format
	Rename-Item "C:\Meditech\ECG\Outbound\$fileNamePDF" -NewName "$time$ss             $ACC          EKG                           $date$tm.pdf"
    }
	#Sleeps script for 1 second between files in order to create unique seconds value for unique 30 character ID if duplicate account numbers exist in 1 batch
    Start-Sleep -Seconds 1
}
Remove-Item "C:\Meditech\ECG\Working\*.*"
Copy-Item "C:\Meditech\ECG\Outbound\*.pdf" -Destination "C:\Meditech\ECG\Archive"
#Move-Item -Path "C:\Meditech\ECG\Outbound\*.pdf" -Destination "\\networkshare\ECM"