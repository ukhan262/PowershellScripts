#!/bin/bash

# Define the Key Vault name
keyVaultName="tested123"

# Get the list of secrets from the Key Vault
secretsList=$(az keyvault secret list --vault-name "$keyVaultName" --query "[].name" --output tsv)

# Initialize an array to store the secret details
secretsArray=()

# Loop through each secret and fetch its value
for secretName in $secretsList; do
    secretValue=$(az keyvault secret show --vault-name "$keyVaultName" --name "$secretName" --query "value" --output tsv)
    # Escape double quotes in the secret value
    secretValue=$(echo "$secretValue" | sed 's/"/\\"/g')
    secretsArray+=("{\"Name\":\"$secretName\",\"Value\":\"$secretValue\"}")
done

# Create the JSON array and convert it to a CSV file
secretsJsonArray=$(IFS=,; echo "[${secretsArray[*]}]")
echo "$secretsJsonArray" | jq -r '.[] | [.Name, .Value] | @csv' > secrets.csv
