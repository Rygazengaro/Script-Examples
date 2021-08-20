#This script takes a large daily inbound zip file of patient statements, finds the account or patient visit number from within each statement, and then names it appropriately for the MEDITECH COLD Feed.
Set-Location -Path C:\Meditech\Statements\Working
$zips = Get-ChildItem -Path "C:\Meditech\Statements\Inbound\*.zip"
ForEach ($zip in $zips) {
	Expand-Archive -Path $zip -DestinationPath C:\Meditech\Statements\Working
	}
Start-Sleep 15
$pdfs = Get-ChildItem -Path "C:\Meditech\Statements\Working\*.pdf"
$pdftotext = "C:\Meditech\Statements\pdftotext.exe"

ForEach ($pdf in $pdfs) {
    Start-Process $pdftotext -ArgumentList $pdf
    Start-Sleep -Milliseconds 15
    }
Start-Sleep -Seconds 30
$files = Get-ChildItem -Path "C:\Meditech\Statements\Working\*.txt"
Write-Host $files
ForEach ($file in $files) {
    $i = 0
    $txt = Select-String -Path $file -Pattern 'VISIT# '
    If ($txt) {
    $substr = $txt.Line.Split(' ')
    $fileName = $file.Name
    $fileNameShort = $fileName.SubString(0,$fileName.Length-4)
    $fileNamePDF = $fileNameShort + '.pdf'
    ForEach ($sstr in $substr) {
    $i++
    if ($sstr -contains "VISIT#") {
        #Write-Host $substr[$i]
        $split1 = $substr[$i].SubString(0,2)
        $strLen = $substr[$i].Length
        $Padding = $strLen-2
        $split2 = $substr[$i].SubString(2,$Padding)
        $split2Pad = $split2.PadLeft(10,'0')
        $ACC = "$split1$split2pad"
        Copy-Item "C:\Meditech\Statements\Working\$fileNamePDF" -Destination "C:\Meditech\Statements\Outbound"
        $time = Get-Date -UFormat "%m%d%Y %H%M%S"
        #Write-Host $time
        Rename-Item "C:\Meditech\Statements\Outbound\$fileNamePDF" -NewName "$time               $ACC          PATSTMT        .pdf"
        }
    }
}
}
Remove-Item C:\Meditech\Statements\Working\*.*
