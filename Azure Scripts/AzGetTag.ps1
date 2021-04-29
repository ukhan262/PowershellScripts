
$rg = Get-AzResourceGroup -Name "rg-origence-ent-uat-01"
$rgResources = Get-AzResource -ResourceGroupName $rg.ResourceGroupName `
    | Select-Object ResourceId,ResourceName `
    | Where-Object ResourceName -eq "cosdb-ent-event-"

Get-AzTag -ResourceId $rgResources.ResourceId


#Get-AzAppServicePlan -Name asp-origence-ent-uat-win-02 | Select-Object Sku


Select-AzSubscription -Subscription "UAT-West"

