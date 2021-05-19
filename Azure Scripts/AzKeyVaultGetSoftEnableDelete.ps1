
<#
    .SYNOPSIS
        This script will get all the apps with a custom domain passing as param value

    .DESCRIPTION
        This script requires couple of parameters
            - $outputFile
            - $hostName
        Commands Used:
            - Connect-AzAccount
            - Get-AzKeyVault

    .EXAMPLE
        .\AzKeyVaultGetSoftEnableDelete.ps1 -outputFile "kvinfo" -softDelete $true
        this will get all the KV that has the enableSoftDelete not set to $true

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $outputFile = $(throw "$outputFile is required"),
    
    [Parameter(Mandatory)]
    [ValidateSet($null, $true, $false)]
    [string] $softDelete = $(throw "$softDelete is required")
)

Connect-AzAccount
$subscriptions = Get-AzSubscription
$subscriptions

$KeyVaults = @()

foreach($sub in $subscriptions)
{
    try {
        Select-AzSubscription -Subscription $sub

        $getKVs = Get-AzKeyVault | Select-Object VaultName
        #$getKVs


        foreach($kv in $getKVs)
        {
            Write-Host $kv.VaultName -ForegroundColor Yellow
            $KeyVaults += Get-AzKeyVault -VaultName $kv.VaultName `
                            | Select-Object @{N='SubscriptionId';E={$_.ResourceId.Split("/")[2]}}, ResourceGroupName, VaultName, EnableSoftDelete -ErrorAction Stop `
                            | Where-Object EnableSoftDelete -NE $softDelete
        }
    }
    catch
    {   
        Write-Host "error" -ForegroundColor Red
        $_.ErrorDetails
    }

    
}

$KeyVaults | Export-Csv -Path ".\$outputFile.csv"