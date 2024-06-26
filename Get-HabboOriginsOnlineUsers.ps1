## Output File
$Outfile = "C:\Users\$env:USERNAME\Documents\habbo-origins-online-user-tracking.txt"

## Output File (.csv)
$CSVOutFile = "C:\Users\$env:USERNAME\Documents\habbo-origins-online-user-tracking.csv"

## Get Timestamp and format
$TodayDate = Get-Date -Format yyyy-MM-dd-hh:mm:ss

## Initialize empty array
$Data = @()

## Craft web request
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0"
$result = Invoke-WebRequest -UseBasicParsing -Uri "https://origins.habbo.com/api/public/origins/users" `
-WebSession $session | Select -ExpandProperty Content

## Convert results from Json and select only the onlineusers number
$FinalObj = $result | ConvertFrom-Json | Select -ExpandProperty OnlineUsers

## Build custom object
$Data += New-Object PSCustomObject -Property @{

Timestamp = $TodayDate;
OnlineUsers = $FinalObj;

}

## Write data to output .txt file specified above
$Data | Write-Output >> $Outfile

## Write output to .csv
$Data | Select-Object Timestamp, OnlineUsers | Sort-Object Timestamp, OnlineUsers | Export-CSV -Path $CSVOutFile -NoTypeInformation -Append
