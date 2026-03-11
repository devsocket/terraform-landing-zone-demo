#!/usr/bin/env bash
set -euo pipefail

LOCATION="canadacentral"
RESOURCE_GROUP="devsocket-tfstate-rg"
MGMT_SUBSCRIPTION_ID="<MANAGEMENT_SUBSCRIPTION_ID>"
STORAGE_ACCOUNT="stlandingzonedemostate"
CONTAINER_NAME="tfstate"

echo "Logging in (ensure 'az' CLI is installed and configured)..."
az account show > /dev/null 2>&1 || az login --use-device-code

echo "Setting subscription..."
az account set --subscription "$MGMT_SUBSCRIPTION_ID"

echo "Registering Microsoft.Storage provider (if not already)..."
az provider register --namespace Microsoft.Storage --subscription "$MGMT_SUBSCRIPTION_ID" > /dev/null

# Wait for registration to complete (up to 5 minutes)
echo "Waiting for provider registration..."
for i in {1..10}; do
  STATE=$(az provider show --namespace Microsoft.Storage --subscription "$MGMT_SUBSCRIPTION_ID" --query "registrationState" -o tsv)
  if [ "$STATE" == "Registered" ]; then
    echo "Provider registered successfully."
    break
  fi
  echo "Still registering... (attempt $i/10)"
  sleep 30
done
if [ "$STATE" != "Registered" ]; then
  echo "Error: Provider registration timed out. Run 'az provider show --namespace Microsoft.Storage --subscription $MGMT_SUBSCRIPTION_ID' manually and wait."
  exit 1
fi

echo "Creating resource group..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --subscription "$MGMT_SUBSCRIPTION_ID" > /dev/null

echo "Creating storage account..."
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --allow-blob-public-access false \
  --min-tls-version TLS1_2 \
  --subscription "$MGMT_SUBSCRIPTION_ID" > /dev/null

ACCOUNT_KEY=$(az storage account keys list \
  --account-name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --subscription "$MGMT_SUBSCRIPTION_ID" \
  --query "[0].value" -o tsv)

echo "Creating Blob container..."
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --account-key "$ACCOUNT_KEY" \
  --subscription "$MGMT_SUBSCRIPTION_ID" > /dev/null

echo "Done!"
echo "Exporting environment variables for Terraform..."
echo "export TFSTATE_RG=${RESOURCE_GROUP}"
echo "export TFSTATE_SA=${STORAGE_ACCOUNT}"
echo "export TFSTATE_CONTAINER=${CONTAINER_NAME}"