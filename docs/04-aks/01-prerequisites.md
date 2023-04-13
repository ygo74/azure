---
layout: default
title: Prerequisites
parent: AKS
nav_order: 1
has_children: false
---

## Tools

### Install kubelogin

Installation is done thanks to azure-cli into your profile directory.

```powershell
az aks install-cli

$env:path += '{0}\.azure-kubelogin' -f $env:USERPROFILE

```

## Variables declaration for Hands On Lab scripts

all scripts defined in the hands on lab demonstration must be defined before executing the commands.

:point_right: **Hands on lab**

``` powershell
# Location
$aksLocation                    = "francecentral"

# Resource groups
$hubResourceGroup               = "rg-francecentral-networking-hub"
$aksresourceGroup               = "rg-aks-bootstrap-networking-spoke"
$aksNodesResourceGroup          = "rg-aks-bootstrap-cluster-nodes"
$aksStorageResourceGroup        = "rg-francecentral-storage-shared"
$managedIdentitiesResourceGroup = "rg-francecentral-managed_identities"

# Virtual network vnet-spoke
$vnetAddressprefix              = "10.240.0.0/16"
$aksVnetName                    = "vnet-spoke"
$nodesSubnetName                = "net-cluster-nodes"
$nodesSubnetAddressprefix       = "10.240.0.0/22"
$servicesSubnetName             = "net-cluster-services"
$servicesSubnetAddressprefix    = "10.240.4.0/28"
$gatewaySubnetName              = "net-application-gateway"
$gatewaySubnetAddressprefix     = "10.240.5.0/24"
$privateLinkSubnetName          = "net-private-links"
$privateLinkSubnetAddressprefix = "10.240.4.32/28"

# Virtual network vnet-hub
$vnetHubName                    = "vnet-hub"

# AKS
$aksName                        = "aksbootstrap"
$aksPublicIpName                = "pi-inventory-gateway"
$aksPublicIpDnsLabel            = "inventory"

# Storage
$aksStorageName                 = "saygo74bootstrap"

# Managed Identities
$aksControlPlaneIdentity        = "umi-aks-bootsrap"
$aksKubeletIdentity             = "umi-aks-bootstrap-kubelet"

# ACR
$acrName                        = "aksbootstrap"

```

## Base resources deployment

### Resources groups

:point_right: [Ensure resources groups have been created](../02-deploy-subscription-root/02-resources-groups.md)

Resources groups used in the deployment are :

* rg-aks-bootstrap-networking-spoke : Container which holds AKS cluster
* rg-acr-bootstrap : Container which holds Azure Container Registry
* rg-francecentral-storage-shared : Container which holds disks and storage accounts
* rg-francecentral-managed_identities : Container which holds user managed identities

:point_right: **Hands on lab**

``` powershell
# Create Hub Resource Group
az group create --name $hubResourceGroup --location $aksLocation

# Create aks bootstrap Resource Group
# The cluster nodes resource group can only be created by the aks cluster during its provisioning
az group create --name $aksresourceGroup --location $aksLocation

# Create storage Resource Group
az group create --name $aksStorageResourceGroup --location $aksLocation

# Create Managed identities Resource Group
az group create --name $managedIdentitiesResourceGroup --location $aksLocation

```

### Virtual Network

:point_right: [Ensure virtual network has been created](../02-deploy-subscription-root/03-virtual-networks.md)

Virtual networks used in the deployment are :

* vnet-spoke : virtual networks dedicated to aks cluster with the followinf subnets :

  * net-cluster-nodes : subnet for cluster's nodes with cidr 10.240.0.0/22
  * net-application-gateway : subnet for external cluster access with cidr 10.240.5.0/24
  * net-private-links : subnet for internal cluster outbound connections with cidr 10.240.4.32/28

Remarks : The cluster services subnet is managed internaly by the cluster during its provisioning with the cidr 10.240.4.0/28. There is no name, neither link into the virtual network

:point_right: **Hands on lab**
{: .text-blue-100 }

``` powershell
# Create Network spoke
az network vnet create --name $aksVnetName --resource-group $aksresourceGroup --address-prefixes $vnetAddressprefix 

# Create subnet for cluster nodes
az network vnet subnet create -g $aksresourceGroup --vnet-name $aksVnetName `
                              -n $nodesSubnetName --address-prefixes $nodesSubnetAddressprefix


# Create subnet for services nodes can be only created by aks cluster during its provisioning
# az network vnet subnet create -g $aksresourceGroup --vnet-name $aksVnetName `
#                               -n $servicesSubnetName --address-prefixes $servicesSubnetAddressprefix

# Create subnet for application gateway
az network vnet subnet create -g $aksresourceGroup --vnet-name $aksVnetName `
                              -n $gatewaySubnetName --address-prefixes $gatewaySubnetAddressprefix

# Create subnet for private links
az network vnet subnet create -g $aksresourceGroup --vnet-name $aksVnetName `
                              -n $privateLinkSubnetName --address-prefixes $privateLinkSubnetAddressprefix

```

### Storages

:point_right: [Ensure storages have been created](../02-deploy-subscription-root/04-storages.md)

storages used in the deployment are :

* saygo74bootstrap : Storage account which holds file shares for the cluster
* 

:point_right: **Hands-on lab**
{: .text-blue-100 }

``` powershell

```

### User Managed Identities

:point_right: [Ensure Managed identities have been created](../02-deploy-subscription-root/05-managed-identities.md)

Managed identities used in the deployment are :

* umi-aks-bootsrap : Cluster control plane identity which will manage access to other resources

  * Public IP
  * Storage
  * Virtual Network

* umi-aks-bootstrap-kubelet : Kubelet identity which will connect to ACR

:point_right: **Hands-on lab**
{: .text-blue-100 }

1. Create aks Identities

    ```powershell
    # Create Control Plane identity
    az identity create --name $aksControlPlaneIdentity --resource-group $managedIdentitiesResourceGroup

    # Create kubelet identity
    az identity create --name $aksKubeletIdentity --resource-group $managedIdentitiesResourceGroup

    ```

2. Grant aks Control Plane Identity to required resources

    2.1. Get Control plane identity

        ```powershell
        # Get Control Plane identity
        $aksControlPlaneIdentityPrincipalId =$(az identity show --name $aksControlPlaneIdentity --resource-group $managedIdentitiesResourceGroup --query "principalId" -o tsv)
        write-host "Aks Control Plane identity Principal Id : $aksControlPlaneIdentityPrincipalId"

        ```

    2.2. Assign Contributor role on Cluster resource group

        ```powershell
        # Get Aks resource group Id
        $aksResourceGroupId = $(az group show -n $aksresourceGroup --query "id" -o tsv)
        if ($null -eq $aksResourceGroupId) { throw "Unable to retrieve aks resource group $aksresourceGroup Id"}
        write-host "Aks Resource group Id : $aksResourceGroupId"

        # Assign role contributor to AKS Identity on AKS resource group
        az role assignment list --scope $aksResourceGroupId
        az role assignment create --assignee $aksControlPlaneIdentityPrincipalId --scope $aksResourceGroupId --role "Contributor"

        ```

    2.3. Assign Network Contributor role on Hub resource group

        ```powershell

        # Get hub resource group Id
        $hubResourceGroupId = $(az group show -n $hubResourceGroup --query "id" -o tsv)
        if ($null -eq $hubResourceGroupId) { throw "Unable to retrieve hub resource group $hubResourceGroup Id"}
        write-host "Aks hub Resource group Id : $hubResourceGroupId"

        # Assign network contributor to AKS Identity on resource group Hub
        az role assignment list --scope $hubResourceGroupId
        az role assignment create --assignee $aksControlPlaneIdentityPrincipalId --scope $hubResourceGroupId --role "Network Contributor"

        ```

    2.4. Assign Storage Account Contributor role on storage resource group

        ```powershell
        # Get storage resource group Id
        $aksStorageResourceGroupId = $(az group show -n $aksStorageResourceGroup --query "id" -o tsv)
        if ($null -eq $aksStorageResourceGroupId) { throw "Unable to retrieve storage resource group $aksStorageResourceGroup Id"}
        write-host "Aks Storage Resource group Id : $aksStorageResourceGroupId"

        # Assign contributor to AKS Identity on storage resource group
        az role assignment list --scope $aksStorageResourceGroupId
        az role assignment create --assignee $aksControlPlaneIdentityPrincipalId --scope $aksStorageResourceGroupId --role "Contributor"
        az role assignment create --assignee $aksControlPlaneIdentityPrincipalId --scope $aksStorageResourceGroupId --role "Storage Account Contributor"

        ```

3. Grant aks Kubelet Identity to required resources

    ```powershell
    # Get kubelet identity
    $aksKubeletIdentityPrincipalId =$(az identity show --name $aksKubeletIdentity --resource-group $managedIdentitiesResourceGroup --query "principalId" -o tsv)
    write-host "Aks Kubelet identity Principal Id : $aksKubeletIdentityPrincipalId"

    # Todo : Grant access to ACR ?
    ```
