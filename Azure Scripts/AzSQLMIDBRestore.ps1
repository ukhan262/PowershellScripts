<#
    This script depends on the BLOB connection to exist on SQL Server
#>

#******************************************
#    Restore Database  
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
    [string[]] $SQL_DB_Name = $(throw "SQL_DB_Name is required"),
    [Parameter(Mandatory)] 
    [string[]] $SQL_DB_Name_New = $(throw "SQL_DB_Name_New is required")
)

$restoreSqlQuery = -join("RESTORE DATABASE [", $SQL_DB_Name_New, "] FROM `
                        URL = '",$BlobStorageURL, "/", $SQL_DB_Name,"-1.bak', `
                        URL = '",$BlobStorageURL, "/", $SQL_DB_Name,"-2.bak', `
                        URL = '",$BlobStorageURL, "/", $SQL_DB_Name,"-3.bak', `
                        URL = '",$BlobStorageURL, "/", $SQL_DB_Name,"-4.bak' `
                        ") 

$restoreSqlQuery

$params = @{
      'ServerInstance' =  $SQL_Server_Name
      'Username' = $SQL_User_Name
      'Password' = $SQL_Password
      'OutputSqlErrors' = $true
      'QueryTimeout' = 600
      'ConnectionTimeout' = 120
      'Query' = $restoreSqlQuery 
    }
    try
    {
        Invoke-Sqlcmd  @params -Verbose
        write-host "restore completed", $SQL_DB_Name_New;
    }
    catch [Microsoft.SqlServer.Management.PowerShell.SqlPowerShellSqlExecutionException]
    {
        Write-Host $Error[0]
    }