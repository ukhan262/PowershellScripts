<#
    this file is dependent on csv file with following columns.
    1. Subscription
    2. ResourceGroupName
    3. AppName

    this script will allow subnets provided in the object $subnet on the appservices
    provided in an .csv file
#>

# Connect-AzAccount
$ErrorActionPreference = "SilentlyContinue"
Import-Module -Name Az


Import-Csv ".\AppServices.csv" |`
ForEach-Object {
    Select-AzSubscription -Subscription $_.Subscription

    $subnets = @(
        ("subnet value 1", "restriction name 1"),
        ("subnet value 2", "restriction name 2"),
        ("subnet value 3", "restriction name 3"),
        ("subnet value 4", "restriction name 4")
    )
    foreach ($subnet in $subnets)
    {
        $ruleName = $subnet[1]
                
        Add-AzWebAppAccessRestrictionRule `
            -ResourceGroupName $_.ResourceGroupName `
            -WebAppName $_.AppName `
            -Name $ruleName -Priority $subnet[1] `
            -Action Allow `
            -IpAddress $subnet[0]
    }
}
