
# RBAC with AKS Managed AAD

Create 2 AAD groups for Web and API 

```
#AKS_ID=$(az aks show \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --query id -o tsv)

WEBDEV_ID=$(az ad group create --display-name webdev --mail-nickname webdev --query objectId -o tsv)
echo $WEBDEV_ID
#aca782d2-fab6-40ca-9b7e-8fcf280c6773
APIDEV_ID=$(az ad group create --display-name apidev --mail-nickname apidev --query objectId -o tsv)
echo $APIDEV_ID
#64ded7a9-b150-4ec5-899f-d96bb6172286
```

Add web-dev users & api-dev users to these groups either from portal or cli

Give these AD groups permissions on namespaces 

```
kaf web-dev-role.yaml
kaf api-dev-role.yaml
```

