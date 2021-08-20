#This script builds a temporary array to compare an excel spreadsheet of employee numbers against photos of employees named by their employee number. 
#This was to convert the file name from the employee number to the employee's name
$excel = Open-ExcelPackage -Path "C:\excel.xlsx"
$WS = $excel.Workbook.Worksheets['Sheet1']
$myArray = @()
For ($i=1;$i -le 2059;$i++) {
$CELLA = "A$i"
$CELLB = "B$i"
$A = $WS.Cells[$CELLA].Value
$B = $WS.Cells[$CELLB].Value
$myArray += ,@($A,$B)
}
#Write-Host $myArray

Get-ChildItem "C:\EPhotos" | 
Foreach-Object {
    $FileName = [System.IO.Path]::GetFileName($_)
    $2ndSplit = $FileName.Split("_")[1]
    For ($x=0;$x -le 2059;$x++){
        #Write-Host $myArray[$x][1]
        #Write-Host $2ndSplit
        if ($2ndSplit -contains $myArray[$x][1]) {
            $Match = $myArray[$x][0]
            Rename-Item -Path "C:\EPhotos\$FileName" -NewName "$Match.jpg"
            }
    }
}