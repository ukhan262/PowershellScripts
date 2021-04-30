<#
    This script depends on the BLOB connection to exist on SQL Server
#>

#******************************************
#    Backup Database  
#******************************************
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $SQL_Server_Name = $(throw "SQL_Server_Name is required"),
    [Parameter(Mandatory)]
    [string] $SQL_User_Name = $(throw "SQL_User_Name is required"),
    [Parameter(Mandatory)]
    [string] $SQL_Password = $(throw "SQL_Password is required"),
    [Parameter(Mandatory)]
    [string] $BlobStorageURL = $(throw "BlobStorageURL is required"),
    [Parameter(Mandatory)] 
    [string[]] $sqlInstanceDatabases = $(throw "sqlInstanceDatabases is required")
)

foreach($instance in $sqlInstanceDatabases)
{
    $SQL_DB_Name = $instance;
    Write-Output $SQL_DB_Name;

    
    $setEncryptionOff = -join("use master; ", "alter database [", $SQL_DB_Name, "] set encryption off;")
    $params = @{
      'ServerInstance' =  $SQL_Server_Name
      'Username' = $SQL_User_Name
      'Password' = $SQL_Password
      'OutputSqlErrors' = $true
      'QueryTimeout' = 600
      'ConnectionTimeout' = 120
      'Query' = $setEncryptionOff 
    }
    try
    {
        Write-Output "set encryption off"
        Invoke-Sqlcmd  @params -Verbose
        Write-Output "___________________________________"
    }
    catch [Microsoft.SqlServer.Management.PowerShell.SqlPowerShellSqlExecutionException]
    {
        Write-Output $Error[0]
    }

    $dropencryptionkey = -join("use [", $SQL_DB_Name, "]; ", "DROP DATABASE ENCRYPTION KEY;  ")
    $params = @{
      'ServerInstance' =  $SQL_Server_Name
      'Username' = $SQL_User_Name
      'Password' = $SQL_Password
      'OutputSqlErrors' = $true
      'QueryTimeout' = 600
      'ConnectionTimeout' = 120
      'Query' = $dropencryptionkey 
    }
    try
    {
        Write-Output "drop encryption key"
        Invoke-Sqlcmd  @params -Verbose
        Write-Output "___________________________________"
    }
    catch [Microsoft.SqlServer.Management.PowerShell.SqlPowerShellSqlExecutionException]
    {
        Write-Output $Error[0]
    }

    Start-Sleep -s 10

    $dropLog = -join("use [", $SQL_DB_Name, "];" ,"DBCC SHRINKFILE (N'log', 1) ")
    $params = @{
      'ServerInstance' =  $SQL_Server_Name
      'Username' = $SQL_User_Name
      'Password' = $SQL_Password
      'OutputSqlErrors' = $true
      'QueryTimeout' = 600
      'ConnectionTimeout' = 120
      'Query' = $dropLog 
    }
    try
    {
        Write-Output "shrink log file"
        Invoke-Sqlcmd  @params -Verbose
        Write-Output "___________________________________"
    }
    catch [Microsoft.SqlServer.Management.PowerShell.SqlPowerShellSqlExecutionException]
    {
        Write-Output $Error[0]
    }

    $backupSqlQuery = -join("BACKUP DATABASE [", $SQL_DB_Name, "] TO `
                        URL = '",$BlobStorageURL, "/", $SQL_DB_Name,"-1.bak', `
                        URL = '",$BlobStorageURL, "/", $SQL_DB_Name,"-2.bak', `
                        URL = '",$BlobStorageURL, "/", $SQL_DB_Name,"-3.bak', `
                        URL = '",$BlobStorageURL, "/", $SQL_DB_Name,"-4.bak' `
                        "," WITH COPY_ONLY") 
    $params = @{
      'ServerInstance' =  $SQL_Server_Name
      'Username' = $SQL_User_Name
      'Password' = $SQL_Password
      'OutputSqlErrors' = $true
      'QueryTimeout' = 600
      'ConnectionTimeout' = 600
      'Query' = $backupSqlQuery 
    }
    try
    {
        Write-Output "starting backup"
        Invoke-Sqlcmd  @params -Verbose
        Write-Output "backup completed", $SQL_DB_Name;
        Write-Output "___________________________________"
    }
    catch [Microsoft.SqlServer.Management.PowerShell.SqlPowerShellSqlExecutionException]
    {
        Write-Output $Error[0]
    }

    $setEncryptionOn = -join("use master; ", "alter database [", $SQL_DB_Name, "] set encryption on;")
    $params = @{
      'ServerInstance' =  $SQL_Server_Name
      'Username' = $SQL_User_Name
      'Password' = $SQL_Password
      'OutputSqlErrors' = $true
      'QueryTimeout' = 600
      'ConnectionTimeout' = 120
      'Query' = $setEncryptionOn 
    }
    try
    {
        Write-Output "set encryption on"
        Invoke-Sqlcmd  @params -Verbose
        Write-Output "___________________________________"
    }
    catch [Microsoft.SqlServer.Management.PowerShell.SqlPowerShellSqlExecutionException]
    {
        Write-Output $Error[0]
    }
    
}