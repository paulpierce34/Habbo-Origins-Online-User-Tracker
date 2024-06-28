## Output File (.txt)
$Outfile = "C:\Users\$env:USERNAME\Documents\habbo-origins-online-user-tracking.txt"

## Output File (.csv)
$CSVOutFile = "C:\Users\$env:USERNAME\Documents\habbo-origins-online-user-tracking.csv"



## Initialize empty array
$Data = @()

$PriceObj = @()

## Craft web request
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0"
$TotalUsersResult = Invoke-WebRequest -UseBasicParsing -Uri "https://origins.habbo.com/api/public/origins/users" `
-WebSession $session | Select -ExpandProperty Content

## Craft web request for item prices API
$AllItems = Invoke-WebRequest -UseBasicParsing -Uri "http://rarevalues.net/api/items" | Select -Expand COntent | ConvertFrom-Json

## Convert online users results from Json and select only the onlineusers number
$FinalUserObj = $TotalUsersResult | ConvertFrom-Json | Select -ExpandProperty OnlineUsers

Foreach ($Furni in $AllItems){

## Get Timestamp and format
$TodayDate = Get-Date -Format yyyy-MM-dd-hh:mm:ss

$Data += New-Object PSCustomObject -Property @{

Furni_Name = $Furni.name;
HC_value = $Furni.hc_value;
Timestamp = $TodayDate;
OnlineUsers = $FinalUserObj;

}

}








## Write data to output .txt file specified above
$Data | Write-Output >> $Outfile

## Write data to .csv output
$Data | Select-Object Timestamp, OnlineUsers, Furni_Name, HC_Value  | Sort-Object Timestamp, OnlineUsers, Furni_Name, HC_Value | Export-CSV -Path $CSVOutFile -NoTypeInformation -Append

## Write output to host if user manually runs script
if (Test-Path $OutFile){
write-host -foregroundcolor Green "`nSuccessfully output file: $Outfile"
}
if (Test-Path $CSVOutfile){
write-host -foregroundcolor Green "Successfully output file: $CSVOutfile"
}
else {
write-host -foregroundcolor Red "Output file not created."
}

write-host -Foregroundcolor Yellow "`nCurrent users online:"
write-output $Data.OnlineUsers[1]

write-host -foregroundcolor Yellow "`nCurrent market Prices:"
$Data | Select furni_name, hc_value

## Function to set-scheduled task on local PC
## Must be run as Admin
function Set-ScheduledHabboTask(){

$DocumentsFolder = [Environment]::GetFolderPath("MyDocuments")

$actions = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument "-file $DocumentsFolder\Get-HabboOriginsOnlineUsers.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At '12:30 AM'
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -WakeToRun -DontStopOnIdleEnd -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1)
$task = New-ScheduledTask -Action $actions -Principal $principal -Trigger $trigger -Settings $settings

Register-ScheduledTask -TaskName 'Get-HabboUsersAndPrices' -InputObject $task

}



## rarevalues api ref:
## /api/items
## /api/prices
