---
layout: default
title: networks commands
parent: Network Management
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

## Virtual network

### Create virtual network

Source : <https://learn.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az-network-vnet-create>

``` powershell
$resourceGroup     = "rg-aks-bootstrap-networking-spoke"
$vnetAddressprefix = "10.240.0.0/16"
$vnetName          = "vnet-spoke"
az network vnet create  `
   --name $vnetName `
   --resource-group $resourceGroup `
   --address-prefixes $vnetAddressprefix 
```

### Get virtual network info

``` powershell
$resourceGroup       = "rg-aks-bootstrap-networking-spoke"
$vnetName            = "vnet-spoke"

az network vnet show -g $aksresourceGroup -n $vnetName --query "id" -o tsv

```

## Subnet

### Create subnet

Source : <https://learn.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-create>

``` powershell
$resourceGroup       = "rg-aks-bootstrap-networking-spoke"
$vnetName            = "vnet-spoke"
$subnetName          = "cluster-nodes-subnet"
$subnetAddressprefix = "10.240.0.0/22"

az network vnet subnet create `
    -g $resourceGroup `
    --vnet-name $vnetName `
    -n $subnetName `
    --address-prefixes $subnetAddressprefix

```

### List subnet

Source : <https://learn.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-list>

```powershell
$resourceGroup     = "rg-aks-bootstrap-networking-spoke"
$vnetName          = "vnet-spoke"

az network vnet subnet list -g $resourceGroup --vnet-name $vnetName
```

### Get subnet info

``` powershell
$resourceGroup       = "rg-aks-bootstrap-networking-spoke"
$vnetName            = "vnet-spoke"
$subnetName          = "cluster-nodes-subnet"

az network vnet subnet show -g $aksresourceGroup --vnet-name $vnetName -n $nodesSubnetName --query "id" -o tsv

```

### Get available ip

Source : <https://learn.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-list-available-ips>

``` powershell
$resourceGroup       = "rg-aks-bootstrap-networking-spoke"
$vnetName            = "vnet-spoke"
$subnetName          = "cluster-nodes-subnet"

az network vnet subnet list-available-ips --resource-group $aksresourceGroup --vnet-name $vnetName -n $nodesSubnetName

```
