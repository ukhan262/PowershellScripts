# Connect-AzAccount

$subscription = ""
$keyvaultName = ""


$fileLocation = ".\embeddedbisecrets.csv"

# Select-AzSubscription -Subscription $subscription
Import-Csv $fileLocation | `
ForEach-Object {
    write-host $_.KeyName
    $Secret = ConvertTo-SecureString -String $_.SecretValue -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $keyvaultName -Name $_.KeyName -SecretValue $Secret
}
