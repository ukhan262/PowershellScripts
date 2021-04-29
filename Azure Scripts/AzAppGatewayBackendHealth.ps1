# Connect-AzAccount
$sub = ""
$rg = ""
$appgateway = ""

Select-AzSubscription -Subscription $sub

Get-AzApplicationGatewayBackendHealth `
        -Name $appgateway `
        -ResourceGroupName $rg `
        | Out-File .\AppGateWay.txt