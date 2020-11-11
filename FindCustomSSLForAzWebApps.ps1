$ErrorActionPreference = "SilentlyContinue"

Import-Module -Name Az


$WAssl = @()

$Subscriptions = Get-AzSubscription
foreach ($sub in $Subscriptions)
{
    $RGs = @()
    Select-AzSubscription -SubscriptionId $sub.Id
    $RGs += Get-AzResourceGroup
    

    foreach($rg in $RGs) {
        $WAs = Get-AzWebApp -ResourceGroupName $rg.ResourceGroupName
        foreach ($wa in $WAs) {
            $WAssl += Get-AzWebAppSSLBinding -ResourceGroupName $rg.ResourceGroupName -WebAppName $wa.Name `
               # | Where-Object {$_.Name -like '*wedgewood-inc.com*'}
        }     
    }
}
$WAssl | ft
