# Azure Kubernetes Services : AKS

Goal : Have Kubernetes cluster on Azure

## Deplowments

### Deploy with Ansible

ansible\aks_create_cluster.yml  

### Deploy with Powershell

cloud\azure\aks\powershell\01-Deploy-AKS.ps1  


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
