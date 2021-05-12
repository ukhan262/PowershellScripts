<#
    .SYNOPSIS
        This script reads from an excel sheet $file.csv. 
        The script must have these 2 columns
            - $_.KeyName
            - $_.SecretValue

    .DESCRIPTION
        This script requires couple of parameters
            - $subscription
            - $keyvaultNam
            - $file
        Commands Used:
            - Connect-AzAccount
            - Set-AzKeyVaultSecret
        The user or the service principle must have GET,SET permissions on the KV

    .EXAMPLE
        .\AzKeyVaultSecretBulkAdd.ps1 -subscription "subname" -keyvaultName "kvname" -file "filenamewithoutextension"

#>
[CmdletBinding()]
param (
    [Parameter(mandatory)]
    [string]
    $subscription = "",
    [Parameter(mandatory)]
    [string]
    $keyvaultName = "",
    [Parameter(mandatory)]
    [string]
    $file = ""
    
)

Connect-AzAccount

$fileLocation = ".\$file.csv"

Select-AzSubscription -Subscription $subscription
Import-Csv $fileLocation | `
ForEach-Object {
    write-host $_.KeyName -ForegroundColor Yellow
    Write-Host $_.SecretValue -ForegroundColor Yellow
    $Secret = ConvertTo-SecureString -String $_.SecretValue -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $keyvaultName -Name $_.KeyName -SecretValue $Secret
}
