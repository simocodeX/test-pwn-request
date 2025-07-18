#!/bin/bash

# In caso di errore, esci
set -e

# Lettura parametro ambiente (default: local → tradotto in dev)
ENV=$1
if [ -z "$ENV" ]; then
  ENV="local"
  echo "No environment specified: using 'local'"
fi

# Installazione yq (necessaria nel runner GitHub)
pip3 install yq

# Se 'local', usa valori da 'dev'
if [ "$ENV" = "local" ]; then
  ENV="dev"
fi

# Estrai nome del Key Vault dal file helm
VAULT=$(yq -r '."microservice-chart".keyvault.name' ../helm/values-$ENV.yaml)

if [[ -z "$VAULT" || "$VAULT" == "null" ]]; then
  echo "❌ Nessun Key Vault trovato in values-$ENV.yaml"
  exit 1
fi

# 🔍 Stampa elenco secrets
echo "🔍  Secrets in vault: $VAULT"
az keyvault secret list --vault-name "$VAULT" -o table

# 🔥 Elimina tutti i secrets
echo -e "\n⚠️  Eliminazione + purge di tutti i secrets nel vault: $VAULT"
for secret in $(az keyvault secret list --vault-name "$VAULT" --query "[].name" -o tsv); do
  echo "➖ Eliminazione secret: $secret"
  az keyvault secret delete --vault-name "$VAULT" --name "$secret"

  # Aspetta che il secret venga messo in stato deleted (può richiedere qualche secondo)
  until az keyvault secret show-deleted --name "$secret" --vault-name "$VAULT" &> /dev/null; do
    echo "⏳ In attesa che '$secret' sia in stato deleted..."
    sleep 3
  done

  echo "🧹 Purge del secret: $secret"
  az keyvault secret purge --vault-name "$VAULT" --name "$secret"
done

echo -e "\n✅ Tutti i secrets sono stati eliminati definitivamente."