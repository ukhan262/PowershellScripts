Select-AzSubscription -Subscription "NonProd-West"
$keyvaultName = "kv-crm-core-dev-01"


# if a value is a JSON object this is how to add it
$Secrets = @{
    "service-specific-azkv-secrets"         = @"
{"obtuseMaxHeap": "3072","obtuseMinHeap": "2048","obtuseFRGroup": "Obtuse Service Dev","obtuseLivenessThreshold": "1000","obtuseReadinessThreshold": "1000","callbackMaxHeap": "3072","callbackMinHeap": "2048","callbackFRGroup": "Callback Service Dev","callbackLivenessThreshold": "1000","callbackReadinessThreshold": "1000","campaignMaxHeap": "13312","campaignMinHeap": "10240","campaignFRGroup": "Campaign Service Dev","campaignLivenessThreshold": "1000","campaignReadinessThreshold": "1000","emailMaxHeap": "13312","emailMinHeap": "10240","emailFRGroup": "Email Service Dev","emailLivenessThreshold": "1000","emailReadinessThreshold": "1000","fileMaxHeap": "12288","fileMinHeap": "10240","fileFRGroup": "File Sync Service Dev","fileLivenessThreshold": "1000","fileReadinessThreshold": "1000","hbadminMaxHeap": "2048","hbadminMinHeap": "1024","hbadminFRGroup": "hbAdmin Service Dev","hbadminLivenessThreshold": "1000","hbadminReadinessThreshold": "1000","importMaxHeap": "1024","importMinHeap": "512","importFRGroup": "Import Service Dev","importLivenessThreshold": "1000","importReadinessThreshold": "1000","importMaxImportThreads": "2","importMaxStreamCrossThreads": "2","legacyImportMaxHeap": "1024","legacyImportMinHeap": "512","legacyImportFRGroup": "Legacy Import Service Dev","legacyImportLivenessThreshold": "1000","legacyImportReadinessThreshold": "1000","legacyImportMaxImportThreads": "1","legacyImportMaxStreamCrossThreads": "1","pointlogMaxHeap": "12288","pointlogMinHeap": "10240","pointlogFRGroup": "Pointlog Service Dev","pointlogLivenessThreshold": "1000","pointlogReadinessThreshold": "1000"}
"@

}

 
foreach($name in $Secrets.Keys)
{
    $Secret = ConvertTo-SecureString -String $Secrets[$name] -AsPlainText -Force
    Set-AzKeyVaultSecret -VaultName $keyvaultName -Name $name -SecretValue $Secret
}

 