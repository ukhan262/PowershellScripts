<#
    this file is dependent on csv file with following columns.
    1. Subscription
    2. ResourceGroup
    3. Name
#>

# Connect-AzAccount
$ErrorActionPreference = "SilentlyContinue"
Import-Module -Name Az

$fileName = ".csv"

Import-Csv ".\$fileName" |`
ForEach-Object {
    Select-AzSubscription -Subscription $_.Subscription
    Remove-AzCosmosDBAccount -Name $_.Name -ResourceGroupName $_.ResourceGroup -PassThru
}

