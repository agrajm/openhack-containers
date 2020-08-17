#!/bin/bash
# script taken directly from https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks

# AKS_RESOURCE_GROUP is *not* the auto-generated one that starts with MC_...
AKS_RESOURCE_GROUP=<my aks cluster resource group>
AKS_CLUSTER_NAME=<my aks cluster name>
ACR_RESOURCE_GROUP=<my acr resource group>
ACR_NAME=<my acr registry name>

# Get the id of the service principal configured for AKS
CLIENT_ID=$(az aks show --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query "servicePrincipalProfile.clientId" --output tsv)

# Get the ACR registry resource id
ACR_ID=$(az acr show --name $ACR_NAME --resource-group $ACR_RESOURCE_GROUP --query "id" --output tsv)

# Create role assignment
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID