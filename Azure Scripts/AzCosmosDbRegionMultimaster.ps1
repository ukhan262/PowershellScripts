<#
    this file is dependent on csv file with following columns.
    1. Subscription
    2. ResourceGroup
    3. Name

    this script will output the status of the cosmos db accounts with multi region status
#>

# Connect-AzAccount

$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = 'SilentlyContinue'

Import-Module -Name Az

$CosmosDbInfo = @()

$fileName = ".csv"

Import-Csv ".\$fileName" |`
ForEach-Object {
    Select-AzSubscription -Subscription $_.Subscription
    $CosmosDbInfo += Get-AzCosmosDBAccount `
        -ResourceGroupName $_.ResourceGroup `
        -Name $_.Name `
            | Select-Object Name, EnableMultipleWriteLocations, ReadLocations, WriteLocations
}

$CosmosDbInfo | Format-Table | Out-File '.\CosmosDBRegionLocation.txt'

Invoke-Item '.\CosmosDBRegionLocation.txt'
