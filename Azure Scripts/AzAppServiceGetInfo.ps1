<#
    .SYNOPSIS
        This script will get all the apps with a custom domain passing as param value

    .DESCRIPTION
        This script requires couple of parameters
            - $outputFile
            - $hostName
        Commands Used:
            - Connect-AzAccount
            - Get-AzWebApp

    .EXAMPLE
        .\AzAppServiceGetInfo.ps1 -outputFile "appinfo1" -hostName "customdomain.com"

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $outputFile = $(throw "$outputFile is required"),
    
    [Parameter(Mandatory)]
    [string] $hostName = $(throw "$hostName is required")
)

# Connect-AzAccount
$subscriptions = Get-AzSubscription
$subscriptions

$appsInfo = @() 
foreach($sub in $subscriptions) {
    Select-AzSubscription -SubscriptionId $sub.Id

    $appsInfo += Get-AzWebApp `
        | foreach-object {$_} `
        | Where-Object {$_.EnabledHostNames -match $hostName} `
        | Select-Object @{name='AppName';expression={$_.Name}} , ResourceGroup, @{name='SubscriptionId';expression={$_.Id.Split("/")[2]}}, @{name='URL';expression={$_.Hostnames.Split(",")[0]}}
}

$appsInfo | Export-Csv -Path ".\$outputFile.csv"