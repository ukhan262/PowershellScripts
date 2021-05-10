Select-AzSubscription -Subscription "sub-name"
$keyvaultName = "kv-name"


# if a value is a JSON object this is how to add it
$Secrets = @{
    "service-specific-azkv-secrets-name"         = "value"

}

 
foreach($name in $Secrets.Keys)
{
    $Secret = ConvertTo-SecureString -String $Secrets[$name] -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $keyvaultName -Name $name -SecretValue $Secret
}

 