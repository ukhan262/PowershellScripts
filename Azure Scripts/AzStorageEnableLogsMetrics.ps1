<#
    This script is depended on a list of all the subscriptions.
    Required Value:
        - $workspaceid

    It will enable metrics on all the storage accounts
#>
# Connect-AzAccount
$ErrorActionPreference = "SilentlyContinue"
Import-Module -Name Az

Import-Csv ".\azuresubscription.csv" |`
ForEach-Object{
    
    #CentralLogAnalytics
    $workspaceid = ""
    Select-AzSubscription -Subscription $_.Name
    
    #storage accounts diagnostics setup
    $storageAccounts = Get-AzStorageAccount | Select-Object Id, StorageAccountName    
    foreach ($stor in $storageAccounts)
    {
        $diagnamesetting = -join($stor.StorageAccountName, "_storage_logs")
        Set-AzDiagnosticSetting -Name $diagnamesetting -ResourceId $stor.Id -WorkspaceId $workspaceid -Enabled $true

        $blobid = -join($stor.id,"/blobServices/default")
        $fileid = -join($stor.id, "/fileServices/default")
        $queueid = -join($stor.id, "/queueServices/default")
        $tableid = -join($stor.id, "/tableServices/default")

        
        $resourcetypeid = @($blobid, $fileid, $queueid, $tableid)
        foreach ($item in $resourcetypeid)
        {
            Set-AzDiagnosticSetting -Name $diagnamesetting -ResourceId $item -WorkspaceId $workspaceid -Enabled $true
        }        
    }
}