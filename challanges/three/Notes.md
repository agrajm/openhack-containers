
# AKS Managed AAD

Create an Azure AD Group for Admins

az ad group create --display-name myAKSAdminGroup --mail-nickname myAKSAdminGroup

# Create an AKS-managed Azure AD cluster

Update the AKS cluster to enable AAD integration and deploy to existing VNet (10.2.0.0/22) and create new subnet for AKS ( 10.2.1.0/24 )


```
RESOURCE_GROUP="teamResources-OpenHackTeam11DryRun"
LOCATION="eastasia"
AKS_CLUSTER_NAME="aksCluster"
VNET_ID=$(az network vnet show --resource-group $RESOURCE_GROUP --name vnet --query id -o tsv)
echo "Vnet ID: $VNET_ID"
# Create aks-subnet
az network vnet subnet create \
  --address-prefixes 10.2.1.0/24 \
  --name aks-subnet \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet
SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name vnet --name aks-subnet --query id -o tsv)
echo "Subnet ID: $SUBNET_ID"

# Create AKS-Admin AD group
AKS_ADMIN_GROUP_ID=$(az ad group create --display-name aksadmingroup --mail-nickname aksadmingroup --query objectId -o tsv)
echo $AKS_ADMIN_GROUP_ID

az aks create \
	--resource-group $RESOURCE_GROUP \
	--name $AKS_CLUSTER_NAME \
	--location $LOCATION \
	--service-cidr 11.0.0.0/24 \
	--dns-service-ip 11.0.0.10 \
  --network-plugin azure \
  --network-policy azure \
	--docker-bridge-address 172.17.0.1/16 \
	--vnet-subnet-id $SUBNET_ID \
	--enable-aad \
  --aad-admin-group-object-ids $AKS_ADMIN_GROUP_ID \
	--node-count 2 \
	--enable-addons monitoring \
  --enable-managed-identity
```

```aad-admin-group-object-ids <id>``` -- Required -- Comma seperated list of aad group object IDs that will be set as cluster admin.


```aad-tenant-id <id>``` -- Optional --  The ID of an Azure Active Directory tenant.

Attach ACR

```
ACR_NAME="registryrjb1641"
az aks update -g $RESOURCE_GROUP -n $AKS_CLUSTER_NAME --attach-acr $ACR_NAME
```

Deploy Workloads

```
k config set-context --current --namespace=api
k create secret generic sql ... 
kaf poi.yaml
kaf trips.yaml
kaf user-java.yaml
kaf userjava.yaml
k config set-context --current --namespace=web
kaf tripviewer.yaml
```

# API Server Authorized IP Ranges

```
az aks update \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER_NAME \
    --api-server-authorized-ip-ranges <range>
```

# RBAC 

Create a RoleBinding for every team members 

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: contoso-cluster-admins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: {{user principal name for current user}}
```

OR 

add them as part of the Managed AAD Group with which AKS cluster is associated
