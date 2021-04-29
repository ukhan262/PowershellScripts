<#
    This script is depended on a list of all the subscriptions.
    Required Value:
        - $sub
        - $workspaceid

    It will enable metrics on all the storage accounts
#>
# Connect-AzAccount

$sub = ""
# exact resource id if it has to go cross subscription
$workspaceid = ""
    
Get-AzSubscription | Where-Object Name -Like $sub | ` 
ForEach-Object {
    Select-AzSubscription -Subscription $_.Name
    
    #storage accounts diagnostics setup
    $storageAccounts = Get-AzStorageAccount | Select-Object Id, StorageAccountName    
    foreach ($stor in $storageAccounts)
    {
        $diagnamesetting = -join($stor.StorageAccountName, "_storage_logs")
        Set-AzDiagnosticSetting -Name $diagnamesetting -ResourceId $stor.Id -WorkspaceId $workspaceid -Enabled $false
        $blobid = -join($stor.id,"/blobServices/default")
        $fileid = -join($stor.id, "/fileServices/default")
        $queueid = -join($stor.id, "/queueServices/default")
        $tableid = -join($stor.id, "/tableServices/default")
    
        $resourcetypeid = @($blobid, $fileid, $queueid, $tableid)
        foreach ($item in $resourcetypeid)
        {
            Set-AzDiagnosticSetting -Name $diagnamesetting -ResourceId $item -WorkspaceId $workspaceid -Enabled $false
            Set-AzDiagnosticSetting -Name $diagnamesetting -ResourceId $item -WorkspaceId $workspaceid -Enabled $true -Category StorageRead, StorageWrite, StorageDelete
        }
    }
}

