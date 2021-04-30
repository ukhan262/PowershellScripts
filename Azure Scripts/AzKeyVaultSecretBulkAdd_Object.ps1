Select-AzSubscription -Subscription "NonProd-West"

$keyvaultName = "kv-crm-core-dev-01"

$values = @(
    ("service-specific-azkv-secrets", "test")
)

foreach($value in $values)

{
    $secretName = $value[0]
    $secretValue = $value[1]

    # Insert and get the secret
    $secretId = (az keyvault secret set -n $secretName --vault-name $keyvaultName --value $secretValue | ConvertFrom-Json).id

    Write-Output "Value 0 =" $secretId
    Write-Output "Value 0 =" $value[0]
    Write-Output "Value 1 =" $value[1]

}

