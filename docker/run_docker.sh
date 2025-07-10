#!/bin/bash

# In caso di errori...
set -e
VAULT=$1
[[ -z "$VAULT" ]] && { echo "vault mancante"; exit 1; }

echo "🔍  Secrets in $VAULT"
az keyvault secret list --vault-name "$VAULT" -o table

# TODO
#echo "🗑️   Purging every secret"
#for s in $(az keyvault secret list --vault-name "$VAULT" --query "[].name" -o tsv); do
#  az keyvault secret delete --vault-name "$VAULT" --name "$s" --yes
#  az keyvault secret purge  --vault-name "$VAULT" --name "$s"
#done

#if [[ "$2" == "--drop" ]]; then
#  echo "🔥  Deleting vault $VAULT"
#  az keyvault delete --name "$VAULT" --resource-group kv-demo-rg
#fi