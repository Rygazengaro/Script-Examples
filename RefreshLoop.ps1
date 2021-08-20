#This script takes 3 tabs in chrome and a word document and switches between those 4 object every 3 minutes. This acts as a display board.
start-process "chrome.exe" "website1"
start-process "chrome.exe" "website2"
start-process "chrome.exe" "website3"
$WordDoc = Get-ChildItem -Path "\\networkshare\teamfolder" | sort LastWriteTime | select -last 1
$WordDocPath = "\\networkshare\teamfolder\$WordDoc"
start-process $WordDocPath
Sleep 5

While ($true) {
    $i = 0
    Do
    {
	    $wshell=New-Object -ComObject wscript.shell;
	    $wshell.AppActivate('Chrome'); # Activate on chrome
	    Sleep 180 # Interval (in seconds) between switch 
	    $wshell.SendKeys('^{PGUP}'); # Ctrl + Page Up keyboard shortcut to switch tab
	    Sleep 1 #Interval (in seconds) between tab switch and refresh
        $wshell.SendKeys('{F5}'); # F5 to refresh active page
    } While (++$i -le 2)
    Do
    {
        $wshell=New-Object -ComObject wscript.shell;
        $wshell.AppActivate('Word'); #Activate on word
        Sleep 180 # Interval (in seconds) to display word doc
    } While (++$i -eq 3)
}