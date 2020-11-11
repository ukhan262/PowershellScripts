$ErrorActionPreference = "SilentlyContinue"

Import-Module -Name Az

$RGs = @()
$WAssl = @()

$Subscriptions = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
Select-AzSubscription -SubscriptionId $Subscriptions
$RGs += Get-AzResourceGroup
    

foreach($rg in $RGs) {
    $WAs = Get-AzWebApp -ResourceGroupName $rg.ResourceGroupName
    foreach ($wa in $WAs) {
        $WAssl += Get-AzWebAppSSLBinding -ResourceGroupName $rg.ResourceGroupName -WebAppName $wa.Name `
            | Where-Object {$_.Name -like '*wedgewood-inc.com*'}
    }     
}

$WAssl | ft
