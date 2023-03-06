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
```

## Get aks available versions

``` powershell
$aksLocation = "francecentral"
az aks get-versions --location $aksLocation --output table
```

## Grant aksCLuster to resource group which contains public IP

``` powershell
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-hub"

$resourceGroupId = $(az group show -n $resourceGroup --query "id" -o tsv)

az role assignment list --scope $resourceGroupId
az role assignment create --assignee $aksIdentity --scope $resourceGroupId --role "Network Contributor"
```
