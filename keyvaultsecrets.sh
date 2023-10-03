#!/bin/bash

clientid=$1
clientsecret=$2
tenantid=$3
subscriptionid=$4
keyvaultname=$5

az login --service-principal -u $clientid -p $clientsecret --tenant $tenantid
az account set -s $subscriptionid

# Azure Key Vault Name
KEY_VAULT_NAME=$keyvaultname

# Get a list of secret names from the Key Vault
SECRET_NAMES=$(az keyvault secret list --vault-name $KEY_VAULT_NAME --query '[].name' -o tsv)

echo "" > data.csv
# Loop through the list of secret names and retrieve their expiration dates
for SECRET_NAME in $SECRET_NAMES; do
    SECRET_EXPIRATION=$(az keyvault secret show --vault-name $KEY_VAULT_NAME --name $SECRET_NAME --query 'attributes.expires' -o tsv) 
    if [ -n "$SECRET_EXPIRATION" ]; then
        echo "Secret '$SECRET_NAME' in Key Vault '$KEY_VAULT_NAME' expires on: $SECRET_EXPIRATION in keyvault: $KEY_VAULT_NAME"
        echo "Secret '$SECRET_NAME' in Key Vault '$KEY_VAULT_NAME' expires on: $SECRET_EXPIRATION in keyvault: $KEY_VAULT_NAME" >> data.csv
    else
        echo "Failed to retrieve expiration date for secret '$SECRET_NAME'."
        echo "Failed to retrieve expiration date for secret '$SECRET_NAME'." >> data.csv
    fi
done
