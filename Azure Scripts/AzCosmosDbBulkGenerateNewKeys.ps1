﻿<#
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
    Write-Host "Before List connection strings"
    $Before += Get-AzCosmosDBAccountKey -ResourceGroupName $_.ResourceGroup `
        -Name $_.Name -Type "ConnectionStrings" | ft
    try {
        New-AzCosmosDBAccountKey -ResourceGroupName $_.ResourceGroup `
        -Name $_.Name -Type "Keys" | ft 
    }
    catch {
        Write-Host "new account key creation failed"
    }
    

    Write-Host "After List connection strings"
    $After += Get-AzCosmosDBAccountKey -ResourceGroupName $_.ResourceGroup `
        -Name $_.Name -Type "ConnectionStrings" | ft

}
