<#
    Azure does not provide a GUI way of stopping an application gateway. This will be used to stop an AG.
    The script depends on the following:
    - subscription name
    - application gateway name
    - resource group name
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $sub = $(throw "subscription is required"),
    [Parameter(Mandatory)]
    [string] $agName = $(throw "application gateway is required"),
    [Parameter(Mandatory)]
    [string] $rgName = $(throw "resource group is required")
)

Select-AzSubscription -Subscription $sub

$appGW = Get-AzApplicationGateway -Name $agName -ResourceGroupName $rgName

Stop-AzApplicationGateway $appGW | Out-File .\azappgateway.txt



