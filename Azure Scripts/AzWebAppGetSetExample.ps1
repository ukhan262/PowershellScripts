<#
    this script will update the sku size on a specific asp
#>
# Connect-AzAccount
$sub = ""
Select-AzSubscription -Subscription $sub

$appserviceplan = ""
$resourcegroup = ""
$webapp = ""
$updateSkuSize = ""

$serviceplan = Get-AzAppServicePlan -ResourceGroupName $resourcegroup -Name $appserviceplan
$serviceplan.Sku

if ($serviceplan.sku -ne $updateSkuSize)
{
    try {
        Stop-AzWebApp -ResourceGroupName $resourcegroup -Name $webapp
        Set-AzAppServicePlan -Name $appserviceplan -ResourceGroupName $resourcegroup -Tier "I3"
        Write-Host "update successful" 
        Start-AzWebApp -ResourceGroupName $resourcegroup -Name $webapp 
    }
    catch {
        Write-Host "failed to update"
    }
    
}



