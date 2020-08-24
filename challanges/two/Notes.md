# Create Infra

RG + VNet + AKS (Kubenet)

```
#!/bin/bash
RESOURCE_GROUP="containersOH"
LOCATION="australiaeast"
AKS_CLUSTER_NAME="aksCluster"
 
echo "Creating Resource Group"
az group create --name $RESOURCE_GROUP -l $LOCATION

echo "Creating VNet for AKS Cluster"
az network vnet create \
	-g $RESOURCE_GROUP \
	-n AKSVNet \
	--address-prefixes 10.3.0.0/22 \
	--subnet-name AKSSubnet \
	--subnet-prefix 10.3.0.0/24

VNET_ID=$(az network vnet show --resource-group $RESOURCE_GROUP --name AKSVNet --query id -o tsv)
echo "Vnet ID: $VNET_ID"
SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name AKSVNet --name AKSSubnet --query id -o tsv)
echo "Subnet ID: $SUBNET_ID"

echo "Create Service Principal"
SERVICE_PRINCIPAL_NAME="aksServicePrincipal"
SP_PASSWD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --query password --output tsv)
# Get the service principle client id.
CLIENT_ID=$(az ad sp show --id http://$SERVICE_PRINCIPAL_NAME --query appId --output tsv)

# Check whether skip-assignment is required while creating SP
# az role assignment create --assignee <appId> --scope $VNET_ID --role  "Network Contributor"

echo "Creating AKS Cluster now....can take several minutes"

az aks create \
	--resource-group $RESOURCE_GROUP \
	--name $AKS_CLUSTER_NAME \
	--location $LOCATION \
	--network-plugin kubenet \
	--service-cidr 10.0.0.0/24 \
	--dns-service-ip 10.0.0.10 \
	--pod-cidr 10.244.0.0/16 \
	--docker-bridge-address 172.17.0.1/16 \
	--vnet-subnet-id $SUBNET_ID \
	--service-principal $CLIENT_ID \
	--client-secret $SP_PASSWD \
	--enable-managed-identity \
	--node-count 2 \
	--enable-addons monitoring


# Get the ACR registry resource id
ACR_NAME="registryrjb1641"
ACR_RESOURCE_GROUP="teamResources"
ACR_ID=$(az acr show --name $ACR_NAME --resource-group $ACR_RESOURCE_GROUP --query "id" --output tsv)

# Create role assignment
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID
```

# Apply Deployments & Services

Build Docker Files for all microservices

```
az acr build -t containersoh/poi:v1 -r $ACR_NAME .
az acr build -t containersoh/trips:v1 -r $ACR_NAME .
az acr build -t containersoh/userjava:v1 -r $ACR_NAME .
az acr build -t containersoh/userprofile:v1 -r $ACR_NAME .
az acr build -t containersoh/tripviewer:v1 -r $ACR_NAME .
```

Create namespaces api & web and deploy accordingly
```
k create ns api
k create ns web

```

# Create Secret for DB in API namespace

```
kubectl config set-context --current --namespace=api

kubectl create secret generic sql \
    --from-literal=SQL_USER=<> \
    --from-literal=SQL_PASSWORD=<> \
    --from-literal=SQL_SERVER=<>.database.windows.net \
    --from-literal=SQL_DBNAME=<>
```