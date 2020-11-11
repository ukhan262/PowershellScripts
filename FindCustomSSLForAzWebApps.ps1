$ErrorActionPreference = "SilentlyContinue"

Import-Module -Name Az

$RGs = @()

$Subscriptions = '118247e6-80ef-4a95-a9cc-3c656affb9ea'
Select-AzSubscription -SubscriptionId $Subscriptions
$RGs += Get-AzResourceGroup
    

foreach($rg in $RGs) {
        $WAs = Get-AzWebApp -ResourceGroupName $rg.ResourceGroupName -ErrorAction SilentlyContinue
        foreach ($wa in $WAs) {
            Get-AzWebAppSSLBinding -ResourceGroupName $rg.ResourceGroupName -WebAppName $wa.Name | Where-Object {$_.Name -like "wedgewood-inc.com"} -ErrorAction SilentlyContinue
        }     
    }
