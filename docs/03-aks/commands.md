---
layout: default
title: aks commands
parent: AKS
nav_order: 3
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

## Get cluster credentials
{: .text-blue-300 }

``` powershell
# Attach using acr-name
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-spoke"

az aks get-credentials --name $aksName --resource-group $resourceGroup --overwrite-existing 

# check if access is well configured
kubectl get nodes

```

## Dashboard access
{: .text-blue-300 }

``` powershell
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-spoke"

az aks browse --name $aksName --resource-group $resourceGroup
```

## Query AKS CLuster identity

``` powershell
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-spoke"

$aksIdentity = $(az aks show --resource-group $resourceGroup --name $aksName --query "identity.principalId" -o tsv)
$aksIdentity

```

## Get aks available versions

``` powershell
$aksLocation = "francecentral"
az aks get-versions --location $aksLocation --output table
```

## Grant aksCLuster to resource group which contains public IP

``` powershell
# Get Aks Identity
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-spoke"

$aksIdentity = $(az aks show --resource-group $resourceGroup --name $aksName --query "identity.principalId" -o tsv)

# Grant network contributor to aks on resource group which contains public ip
$aksName       = "aksbootstrap"
$resourceGroup = "rg-francecentral-networking-hub"

$resourceGroupId = $(az group show -n $resourceGroup --query "id" -o tsv)

az role assignment list --scope $resourceGroupId
az role assignment create --assignee $aksIdentity --scope $resourceGroupId --role "Network Contributor"
```

## Attach ACR to cluster

Directory Readers for service principal ?

``` powershell
# Attach using acr-name
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-spoke"
$acrName       = "aksbootstrap"

az aks update -n $aksName -g $resourceGroup  --attach-acr $acrName --enable-managed-identity

az aks check-acr --resource-group $resourceGroup --name $aksName --acr $acrName
```

 $resourceID=$(az acr show --resource-group rg-acr-bootstrap --name aksbootstrap --query id --output tsv) 


## Get aks nodes group

``` powershell
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-spoke"

$aksNodesResourceGroupaz = $(az aks show --resource-group $resourceGroup --name $aksName --query nodeResourceGroup -o tsv)
write-host "Node resources group is : $aksNodesResourceGroupaz"

```



## Deprecated

### Grant AKS service To ACR (Deprecated)

``` powershell
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

# [2022-02-09T05:43:29Z] Checking ACR location matches cluster location: FAILED
# [2022-02-09T05:43:29Z] ACR location 'westeurope' does not match your cluster location 'francecentral'. This may result in slow image pulls and extra cost.

# replaced by
az aks update --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --attach-acr $ACR_NAME

az aks check-acr --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --acr $ACR_HOSTNAME

```
