<#
    this file is dependent on csv file with following columns.
    1. Subscription
    2. ResourceGroup
    3. Name
#>

# Connect-AzAccount
$ErrorActionPreference = "SilentlyContinue"
Import-Module -Name Az

$After = @()
$Before = @()

$fileName = ".csv"

Import-Csv ".\$fileName" |`
ForEach-Object { 
    Select-AzSubscription -Subscription $_.Subscription
    $Before += Get-AzCosmosDBAccount `
        -ResourceGroupName $_.ResourceGroup `
        -Name $_.Name `
            | Select-Object Name,EnableMultipleWriteLocations
    try {        
        Update-AzCosmosDBAccount `
            -ResourceGroupName $_.ResourceGroup `
            -Name $_.Name  `
            -EnableMultipleWriteLocations:$false
    }
    catch {
        Write-Output "update failed"
    }

    $After += Get-AzCosmosDBAccount `
        -ResourceGroupName $_.ResourceGroup `
        -Name $_.Name `
            | Select-Object Name,EnableMultipleWriteLocations

}

$Before | Format-Table |  Out-File .\AzCosmosDbAccountBefore.txt
$After | Format-Table |  Out-File .\AzCosmosDbAccountAfter.txt

notepad .\AzCosmosDbAccountAfter.txt