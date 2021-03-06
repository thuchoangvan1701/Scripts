## Terminal Services RDP Sessions: PowerShell Script to send an Email Report on All Active RDP Sessions ##

## Requires Active Directory PowerShell module and the QWINSTA command (ships with Windows 2008 R2) and normally located in 'C:\Windows\System32'
## Usage: Edit the email parameters under'Setup email parameters' and possibly changes the path to qwinsta.exe under '$queryResults'

# Import the Active Directory module for the Get-ADComputer CmdLet 
Import-Module ActiveDirectory 
 
# Get today's date for the report 
$today = Get-Date 
 
# Setup email parameters 
$subject = "ACTIVE SERVER SESSIONS REPORT - " + $today 
$priority = "Normal" 
$smtpServer = "yoursmtpserver.com" 
$emailFrom = "emailfrom@yourdomain.com"
$emailTo = "emailto@yourdomain.com"
 
# Create a fresh variable to collect the results. You can use this to output as desired 
$SessionList = "ACTIVE SERVER SESSIONS REPORT - " + $today + "`n`n" 
 
# Query Active Directory for computers running a Server operating system 
$Servers = Get-ADComputer -Filter {OperatingSystem -like "*server*"} 
 
# Loop through the list to query each server for login sessions 
ForEach ($Server in $Servers) { 
    $ServerName = $Server.Name 
 
    # When running interactively, uncomment the Write-Host line below to show which server is being queried 
    # Write-Host "Querying $ServerName" 
 
    # Run the qwinsta.exe and parse the output (the qwinsta.exe tool can normally be found in most windows servers in the 'C:\Windows\System32' folder)
    $queryResults = (C:\Windows\System32/qwinsta /server:$ServerName | foreach { (($_.trim() -replace "\s+",","))} | ConvertFrom-Csv)  
     
    # Pull the session information from each instance 
    ForEach ($queryResult in $queryResults) { 
        $RDPUser = $queryResult.USERNAME 
        $sessionType = $queryResult.SESSIONNAME 
         
        # We only want to display where a "person" is logged in. Otherwise unused sessions show up as USERNAME as a number 
        If (($RDPUser -match "[a-z]") -and ($RDPUser -ne $NULL)) {  
            # When running interactively, uncomment the Write-Host line below to show the output to screen 
            # Write-Host $ServerName logged in by $RDPUser on $sessionType 
            $SessionList = $SessionList + "`n`n" + $ServerName + " logged in by " + $RDPUser + " on " + $sessionType 
        } 
    } 
} 
 
# Send the report email 
Send-MailMessage -To $emailTo -Subject $subject -Body $SessionList -SmtpServer $smtpServer -From $emailFrom -Priority $priority 
 
# When running interactively, uncomment the Write-Host line below to see the full list on screen 
$SessionList 