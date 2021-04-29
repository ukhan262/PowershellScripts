# Set SQL Server instance name
$sqlName= ""
 
# Set the databse name which you want to backup
$dbname= ""
 
# Set the backup file path
$backupPath= "D:\DBBackups\$dbname.bak"
 
#Load the required assemlies SMO and SmoExtended.
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
 
# Connect SQL Server.
$sqlServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $sqlName
 
#Create SMO Backup object instance with the Microsoft.SqlServer.Management.Smo.Backup
$dbBackup = new-object ("Microsoft.SqlServer.Management.Smo.Backup")
 
$dbBackup.Database = $dbname
 
#Add the backup file to the Devices
$dbBackup.Devices.AddDevice($backupPath, "File")
 
#Set the Action as Database to generate a FULL backup 
$dbBackup.Action="Database"
 
#Call the SqlBackup method to complete backup 
$dbBackup.SqlBackup($sqlServer)
 
Write-Host "...Backup of the database"$dbname" completed..."