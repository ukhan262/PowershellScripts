<#
    This will list all secrets in KV
#>

# Connect-AzAccount
$sub = ""
Select-AzSubscription -Subscription $sub

$keyvault = ""

$keyVaultSecrets = Get-AzKeyVaultSecret -VaultName $keyvault

foreach ($secret in $keyVaultSecrets.Name)
{
    $secretInPlainText = $secret.SecretValue | ConvertFrom-SecureString -AsPlainText
    Write-Host $secret ":" $secretInPlainText
}