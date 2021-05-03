###########################################################################
############################################################################
$sub = "";
az login
az account set --subscription $sub
az account show

$keyvaultName     = "kvname"
 
$fileLocation = ".\KV.csv"
Import-Csv $fileLocation | `
ForEach-Object{

    $secretName = $_.SecretName
    $secretValue = $_.SecretValue
    # Insert and get the secret 
    $secretId = (az keyvault secret set -n $secretName --vault-name $keyvaultName --value $secretValue | ConvertFrom-Json).id
    $secretId
    
    Write-Output "Value 0 =" $secretName
    Write-Output "Value 1 =" $secretValue
}

 

###############################################################
###############################################################