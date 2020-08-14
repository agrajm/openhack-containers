# Create Infra

RG + AKS (Kubenet)

```
export resourceGroup=containersOH
export location=australiaeast
export aksClusterName=aksCluster
 
az group create -name $resourceGroup -l $location

az aks create -g $resourceGroup \
			-n $aksClusterName \
			--enable-managed-identity \
			--node-count 1 \
--enable-addons monitoring
```

