<#
    .SYNOPSIS
        This script will get all the apps with a custom domain passing as param value

    .DESCRIPTION
        This script requires couple of parameters
            - $outputFile
            - $hostName
        Commands Used:
            - Connect-AzAccount
            - SGet-AzWebApp

    .EXAMPLE
        .\AzAppServiceGetInfo.ps1 -outputFile "appinfo" -hostName "customdomainname"

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $outputFile = $(throw "$outputFile is required"),
    
    [Parameter(AttributeValues)]
    [string] $hostName = $(throw "$hostName is required")
)

Connect-AzAccount
$subscriptions = Get-AzSubscription
$subscriptions

$appsInfo = @() 
foreach($sub in $subscriptions) {
    Select-AzSubscription -SubscriptionId $sub.Id

    $appsInfo += Get-AzWebApp `
        | foreach-object {$_} `
        | Where-Object {$_.EnabledHostNames -match $hostName} `
        | Select-Object Name, ResourceGroup, @{N='SubscriptionId';E={$_.Id.Split("/")[2]}}
}

$appsInfo | Export-Csv -Path ".\$outputFile.csv"