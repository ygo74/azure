# Azure Kubernetes Services : AKS
Goal : Have Kubernetes cluster on Azure

## Deplowments
### Deploy with Ansible
TODO

### Deploy with Powershell

## Operations
### Connect to AKS
TODO


```powershell
$AKS_RESOURCE_GROUP="AKS"
$AKS_CLUSTER_NAME="aksCluster"

ACR_RESOURCE_GROUP=myACRResourceGroup
ACR_NAME=myACRRegistry

# Get the id of the service principal configured for AKS
$CLIENT_ID= (az aks show --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query "servicePrincipalProfile.clientId" --output tsv)

# Get the ACR registry resource id
$registry = Get-AzureRmContainerRegistry -ResourceGroupName "AKS" -Name mesfContainerRegistry
##ACR_ID=$(az acr show --name $ACR_NAME --resource-group $ACR_RESOURCE_GROUP --query "id" --output tsv)

# Create role assignment
New-AzureRmRoleAssignment  -ObjectId $CLIENT_ID  -RoleDefinitionName Reader -Scope $registry.Id
## az role assignment create --assignee $CLIENT_ID --role Reader --scope $ACR_ID
```