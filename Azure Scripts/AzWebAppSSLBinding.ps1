
$ErrorActionPreference = "SilentlyContinue"

Import-Module -Name Az

$WAssl = @()
$certName = ""
$Subscriptions = Get-AzSubscription

foreach ($sub in $Subscriptions)
{
    $RGs = @()
    Select-AzSubscription -SubscriptionId $sub.Id
    $RGs += Get-AzResourceGroup

    $RGs | Format-Table
    
    foreach($rg in $RGs) {
        $WAs = Get-AzWebApp -ResourceGroupName $rg.ResourceGroupName
        foreach ($wa in $WAs) {
            
            $WAssl += Get-AzWebAppSSLBinding -ResourceGroupName $rg.ResourceGroupName -WebAppName $wa.Name `
                | Where-Object {$_.Name -like '*$certName*'}
        }     
    }
}

$WAssl | Format-Table