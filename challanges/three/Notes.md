
# AKS Managed AAD

Create an Azure AD Group for Admins

az ad group create --display-name myAKSAdminGroup --mail-nickname myAKSAdminGroup

# Create an AKS-managed Azure AD cluster

Update the AKS cluster to enable AAD integration and deploy to existing VNet (10.2.0.0/22) and create new subnet for AKS ( 10.2.1.0/24 )

RESOURCE_GROUP="teamResources"

VNET_ID=$(az network vnet show --resource-group $RESOURCE_GROUP --name vnet --query id -o tsv)
echo "Vnet ID: $VNET_ID"
SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name vnet --name aks-subnet --query id -o tsv)
echo "Subnet ID: $SUBNET_ID"

```
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
  --aad-admin-group-object-ids b74f41ac-ccd0-4e07-b279-27516aea993f \
	--node-count 2 \
	--enable-addons monitoring
```

```aad-admin-group-object-ids <id>``` -- Required -- Comma seperated list of aad group object IDs that will be set as cluster admin.


```aad-tenant-id <id>``` -- Optional --  The ID of an Azure Active Directory tenant.



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
