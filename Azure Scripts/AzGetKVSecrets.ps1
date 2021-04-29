$keyvaultName = "dev-enterprise-cudc-kv"

$secrets = Get-AzKeyVaultSecret -VaultName $keyvaultName

$keys =@{}
foreach ($secret in $secrets)
    {
        $secretName = $secret.name

        $key = (Get-AzKeyVaultSecret -VaultName $keyvaultName -name $secretName).SecretValueText
        $keys.Add("$secretName", "$key")
    }