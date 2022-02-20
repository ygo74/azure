---
layout: default
title: Create Cluster
parent: AKS
nav_order: 2
has_children: false
---

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

## Create Cluster

## Init Credential

```powershell
az aks get-credentials --resource-group $azResourceGroup.ResourceGroupName `
                       --name $inventoryVars.aks.cluster_name

kubectl get nodes

```

## Sanity check cluster creation

1. Deploy test application

    ```powershell

    kubectl apply -f .\aks\resources\application_samples.yml

    kubectl get pods

    kubectl get service azure-vote-front --watch

    ```

2. Remove test application

    ```powershell
    kubectl delete -f .\aks\resources\application_samples.yml

    ```

## Dashboard access

1. Azure dashboard

    ```powershell

    az aks browse --name MyManagedCluster --resource-group MyResourceGroup
    ```

2. Standard Kubernetes dashboard

    ```powershell
    # Install standard Kubernetes dashboard
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml

    # Full access to dashboard : Not recommended. TODO Check for best practices
    # TODO : Check if required
    # kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

    # Enable from local Uri
    kubectl proxy

    ```

    Dashboard uri : <http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/>

## Link to Azure Container Registry

:warning: ACR and AKS should be in the same location

```powershell
$AKS_RESOURCE_GROUP="AKS"
$ACR_RESOURCE_GROUP="ACR"
$AKS_CLUSTER_NAME="aksCluster"
$ACR_NAME="mesfContainerRegistry"
$ACR_HOSTNAME="mesfcontainerregistry.azurecr.io"

<# Old Method

# Get the id of the service principal configured for AKS
$CLIENT_ID= (az aks show --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --query "servicePrincipalProfile.clientId" --output tsv)

# Get the ACR registry resource id
$registry = Get-AzContainerRegistry -ResourceGroupName $ACR_RESOURCE_GROUP -name $ACR_NAME ##ACR_ID=$(az acr show --name $ACR_NAME --resource-group $ACR_RESOURCE_GROUP --query "id" --output tsv)

# Create role assignment
# az role assignment create --assignee $CLIENT_ID --role Reader --scope $registry.Id
#>

az aks update --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --attach-acr $ACR_NAME

az aks check-acr --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --acr $ACR_HOSTNAME
# [2022-02-09T05:43:29Z] Checking ACR location matches cluster location: FAILED
# [2022-02-09T05:43:29Z] ACR location 'westeurope' does not match your cluster location 'francecentral'. This may result in slow image pulls and extra cost.
```
