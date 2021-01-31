# Azure Kubernetes Services : AKS
Goal : Have Kubernetes cluster on Azure

## Deplowments
### Deploy with Ansible
ansible\aks_create_cluster.yml  

### Deploy with Powershell
cloud\azure\aks\powershell\01-Deploy-AKS.ps1  

### Configure access from AKS to ACR
```powershell
$AKS_RESOURCE_GROUP="AKS"
$ACR_RESOURCE_GROUP="ACR"
$AKS_CLUSTER_NAME="aksCluster"
$ACR_NAME="mesfContainerRegistry"

# Get the id of the service principal configured for AKS
$CLIENT_ID= (az aks show --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query "servicePrincipalProfile.clientId" --output tsv)

# Get the ACR registry resource id
$registry = Get-AzContainerRegistry -ResourceGroupName $ACR_RESOURCE_GROUP -name $ACR_NAME ##ACR_ID=$(az acr show --name $ACR_NAME --resource-group $ACR_RESOURCE_GROUP --query "id" --output tsv)

# Create role assignment
az role assignment create --assignee $CLIENT_ID --role Reader --scope $registry.Id
```

## Operations
### Connect to AKS
```powershell
$aksClusterName    = "aksCluster"
$ResourceGroupName = "AKS"
az aks get-credentials --resource-group $ResourceGroupName  --name $aksClusterName  

# Full access to dashboard : Not recommended. TODO Check for best practices
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

az aks browse -g $ResourceGroupName -n $aksClusterName
```