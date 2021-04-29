# Connect-AzAccount
$AppGWs = @()

$sub = ''
$rg = ''
$appgatewayName = ''

Select-AzSubscription -SubscriptionID $sub
$AppGW = Get-AzApplicationGateway -ResourceGroupName $rg -Name $appgatewayName

$AppGWs += Get-AzApplicationGatewaySslCertificate -ApplicationGateway $AppGW `
    | Where-Object {$_.Name -like '*certificate-name*'}

