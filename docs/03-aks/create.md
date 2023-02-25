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
{: .text-blue-300 }

### Deploy with ansible
{: .text-blue-200 }

```bash
cd .\cloud\azure\ansible
# Mount azure credentials
docker run --rm -it -v C:\Users\Administrator\azure_config_ansible.cfg:/root/.azure/credentials -v "$(Get-Location):/myapp:rw" -w /myapp local/ansible bash

# Use environment file
docker run --rm -it --env-file C:\Users\Administrator\azure_credentials  -v "$(Get-Location):/myapp:rw" -w /myapp local/ansible bash

ansible-playbook aks_create_cluster.yml -i inventory/
```

### Deploy with powershell
{: .text-blue-200 }

``` powershell
cd .\cloud\azure\powershell

& .\scripts\aks\01-Deploy-AKS.ps1  
```

## Get cluster credentials
{: .text-blue-300 }

``` powershell
# Attach using acr-name
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-spoke"

az aks get-credentials --name $aksName --resource-group $resourceGroup

# check if access is well configured
kubectl get nodes

```

## Cluster configuration
{: .text-blue-300 }

### additional configuration
{: .text-blue-200 }

{: .warning-title }
> Deployment location
>
> ACR and AKS should be in the same location

``` powershell
# Attach using acr-name
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-spoke"
$acrName       = "aksbootstrap"

az aks update -n $aksName -g $resourceGroup  --attach-acr $acrName --enable-managed-identity

az aks check-acr --resource-group $resourceGroup --name $aksName --acr $acrName
```

### Standard Kubernetes dashboard
{: .text-blue-200 }

TODO See Kubernetes doc


### Grant AKS service identity to virtual network
{: .text-blue-200 }


``` powershell
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-spoke"

# Get the id of the service principal configured for AKS
$aks_identity= $(az identity show -n aksbootstrap-agentpool -g rg-aks-aksbootstrap-node --query "id" --output tsv)



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
