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

### Prerequisites

* ACR has been deployed

* script variables have been loaded

    ```powershell
    # Resource group and network
    $aksLocation                    = "francecentral"
    $aksresourceGroup               = "rg-aks-bootstrap-networking-spoke"
    $vnetAddressprefix              = "10.240.0.0/16"
    $vnetName                       = "vnet-spoke"
    $nodesSubnetName                = "cluster-nodes-subnet"
    $nodesSubnetAddressprefix       = "10.240.0.0/22"
    $servicesSubnetName             = "cluster-services-subnet"
    $servicesSubnetAddressprefix    = "10.240.4.0/28"
    $gatewaySubnetName              = "application-gateway-subnet"
    $gatewaySubnetAddressprefix     = "10.240.5.0/24"
    $privateLinkSubnetName          = "private-links-subnet"
    $privateLinkSubnetAddressprefix = "10.240.4.32/28"


    # AKS
    $aksName                  = "aksbootstrap"
    $aksPublicIpName          = "pi-inventory-gateway"
    $aksPublicIpDnsLabel      = "inventory"

    # ACR
    $acrName                  = "aksbootstrap"

    ```

### Create resource group and network spoke for aks

1. Create resource Group

    ``` powershell
    # Create Resource Group
    az group create --name $aksresourceGroup --location $aksLocation

    ```

2. Create network spoke

    ``` powershell
    # Create Network spoke
    az group create --name $aksresourceGroup --location $aksLocation
    az network vnet create  `
        --name $vnetName `
        --resource-group $resourceGroup `
        --address-prefixes $vnetAddressprefix 

    # Create subnet for cluster nodes
    az network vnet subnet create `
        -g $resourceGroup `
        --vnet-name $vnetName `
        -n $nodesSubnetName `
        --address-prefixes $nodesSubnetAddressprefix

    # Create subnet for services nodes
    az network vnet subnet create `
        -g $resourceGroup `
        --vnet-name $vnetName `
        -n $servicesSubnetName `
        --address-prefixes $servicesSubnetAddressprefix

    # Create subnet for application gateway
    az network vnet subnet create `
        -g $resourceGroup `
        --vnet-name $vnetName `
        -n $gatewaySubnetName `
        --address-prefixes $gatewaySubnetAddressprefix

    # Create subnet for private links
    az network vnet subnet create `
        -g $resourceGroup `
        --vnet-name $vnetName `
        -n $privateLinkSubnetName `
        --address-prefixes $privateLinkSubnetAddressprefix

    ```


### Create AKS cluster

``` powershell
# Get subnet id
$subnetNodeId = $(az network vnet subnet show -g $aksresourceGroup --vnet-name $vnetName -n $nodesSubnetName --query "id" -o tsv)

az aks create `
    --resource-group $aksresourceGroup `
    --name $aksName `
    --kubernetes-version 1.24.9 `
    --node-count 2 `
    --generate-ssh-keys `
    --enable-managed-identity `
    --attach-acr $acrName `
    --load-balancer-sku Standard `
    --network-plugin azure `
    --vnet-subnet-id $subnetNodeId `
    --service-cidr $servicesSubnetAddressprefix `
    --dns-service-ip 10.240.4.2

```

## Automatic deployment

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
# Get Aks Identity
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-spoke"

$aksIdentity = $(az aks show --resource-group $resourceGroup --name $aksName --query "identity.principalId" -o tsv)

# Assign network contributor to AKS Identity on resource group Hub
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-hub"

$resourceGroupId = $(az group show -n $resourceGroup --query "id" -o tsv)

az role assignment list --scope $resourceGroupId
az role assignment create --assignee $aksIdentity --scope $resourceGroupId --role "Network Contributor"

```

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
