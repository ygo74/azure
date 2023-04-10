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

## Prerequisites

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

    # Resource group and vnet hub
    $hubResourceGroup               = "rg-francecentral-networking-hub"
    $vnetHubName                    = "vnet-hub"

    # AKS
    $aksName                  = "aksbootstrap"
    $aksPublicIpName          = "pi-inventory-gateway"
    $aksPublicIpDnsLabel      = "inventory"
    $aksStorageName           = "staygo74bootstrap"
    $aksStorageResourceGroup  = "rg-francecentral-storage-shared"

    # ACR
    $acrName                  = "aksbootstrap"

    ```

## Create Cluster

### Create resource group and network spoke for aks

1. Create resource Group

    ``` powershell
    # Create Resource Group
    az group create --name $aksresourceGroup --location $aksLocation

    ```

2. Create network spoke

    ``` powershell
    # Create Network spoke
    az network vnet create  `
        --name $vnetName `
        --resource-group $aksresourceGroup `
        --address-prefixes $vnetAddressprefix 

    # Create subnet for cluster nodes
    az network vnet subnet create `
        -g $aksresourceGroup `
        --vnet-name $vnetName `
        -n $nodesSubnetName `
        --address-prefixes $nodesSubnetAddressprefix

    # Create subnet for services nodes
    # az network vnet subnet create `
    #     -g $aksresourceGroup `
    #     --vnet-name $vnetName `
    #     -n $servicesSubnetName `
    #     --address-prefixes $servicesSubnetAddressprefix

    # Create subnet for application gateway
    az network vnet subnet create `
        -g $aksresourceGroup `
        --vnet-name $vnetName `
        -n $gatewaySubnetName `
        --address-prefixes $gatewaySubnetAddressprefix

    # Create subnet for private links
    az network vnet subnet create `
        -g $aksresourceGroup `
        --vnet-name $vnetName `
        -n $privateLinkSubnetName `
        --address-prefixes $privateLinkSubnetAddressprefix

    ```

### Create Aks Identity

```powershell
# Create identity
az identity create --name aksIdentity --resource-group $aksresourceGroup
$aksIdentityPrincipalId =$(az identity show --name aksIdentity --resource-group $aksresourceGroup --query "principalId" -o tsv)
write-host "Aks identity Principal Id : $aksIdentityPrincipalId"


# Get resource group Id
$aksResourceGroupId = $(az group show -n $aksresourceGroup --query "id" -o tsv)
if ($null -eq $aksResourceGroupId) { throw "Unable to retrieve aks resource group $aksResourceGroupId Id"}
write-host "Aks Resource group Id : $aksResourceGroupId"

# Assign network contributor to AKS Identity on resource group Hub
az role assignment list --scope $aksResourceGroupId
az role assignment create --assignee $aksIdentityPrincipalId --scope $aksResourceGroupId --role "Contributor"

```

### Create AKS cluster

``` powershell
# Get subnet id
$subnetNodeId = $(az network vnet subnet show -g $aksresourceGroup --vnet-name $vnetName -n $nodesSubnetName --query "id" -o tsv)
write-host "Subnet node Id : $subnetNodeId"

# Get Identity resource Id
$aksIdentityResourceId =$(az identity show --name aksIdentity --resource-group $aksresourceGroup --query "id" -o tsv)
write-host "Aks identity resource id : $aksIdentityResourceId"


az aks create `
    --resource-group $aksresourceGroup `
    --name $aksName `
    --kubernetes-version 1.24.9 `
    --node-resource-group rg-aks-$aksName-node `
    --node-count 2 `
    --generate-ssh-keys `
    --attach-acr $acrName `
    --load-balancer-sku Standard `
    --network-plugin azure `
    --vnet-subnet-id $subnetNodeId `
    --service-cidr $servicesSubnetAddressprefix `
    --dns-service-ip 10.240.4.2 `
    --enable-managed-identity `
    --assign-identity $aksIdentityResourceId

```

## Cluster configuration

### Connect to AKS Cluster

``` powershell
# Get cluster configuration
az aks get-credentials --name $aksName --resource-group $aksresourceGroup --overwrite-existing 

# Check if access is well configured
kubectl get nodes

```

### Attach ACR and enable managed identity

{: .warning-title }
> Deployment location
>
> ACR and AKS should be in the same location

``` powershell
# Attach using acr-name
az aks update -n $aksName -g $aksresourceGroup  --attach-acr $acrName --enable-managed-identity

az aks check-acr --resource-group $aksresourceGroup --name $aksName --acr $acrName
```

### Standard Kubernetes dashboard

``` powershell
# Deploy standard kubernetes dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

```

{: .information-title }
> Access to the standard dashboard
>
> kubectl proxy
> <http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/>

### Grant AKS service identity to virtual network

``` powershell
# Get Aks Identity
$aksIdentity = $(az aks show --resource-group $aksresourceGroup --name $aksName --query "identity.principalId" -o tsv)
if ($null -eq $aksIdentity) { throw "Unable to retrieve aks $aksName identity in resource group $resourceGroup"}
write-host "Aks identity : $aksIdentity"

# Get resource group Id
$hubResourceGroupId = $(az group show -n $hubResourceGroup --query "id" -o tsv)
if ($null -eq $hubResourceGroupId) { throw "Unable to retrieve hub resource group $hubResourceGroup Id"}
write-host "Hub Resource group Id : $hubResourceGroupId"
$hubResourceGroupId

# Assign network contributor to AKS Identity on resource group Hub
az role assignment list --scope $hubResourceGroupId
az role assignment create --assignee $aksIdentity --scope $hubResourceGroupId --role "Network Contributor"

```

## Deploy Cert Manager

### Configure namespace for Cert Manager

``` powershell
kubectl create namespace cert-manager
kubectl label namespace cert-manager cert-manager.io/disable-validation=true

```

### Add jetstack repo

``` powershell
# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

```

### Deploy cert manager

``` powershell
helm upgrade cert-manager jetstack/cert-manager `
  --install `
  --namespace cert-manager `
  --set installCRDs=true `
  --set nodeSelector."kubernetes\.io/os"=linux

kubectl apply -f .\containers\kubernetes\configuration\cert-manager\02-cluster-issuer.yaml

```

## Deploy ingress controller

### Configure namespace for ingress controller

``` powershell
kubectl create namespace ingress-controller
kubectl label namespace ingress-controller cert-manager.io/disable-validation=true

```

### Add jetstack repo

``` powershell
# Add the  ingress-nginx Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Update your local Helm chart repository cache
helm repo update
```

### Create public IP for the Ingress

``` powershell
# CREATE IP
az network public-ip create --resource-group $hubResourceGroup --name $aksPublicIpName --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv
# DNS Label
az network public-ip update -g $hubResourceGroup -n $aksPublicIpName --dns-name $aksPublicIpDnsLabel --allocation-method Static
# fqdn testygo.eastus.cloudapp.azure.com
# fqdn testygo.francecentral.cloudapp.azure.com

$publicIp = $(az network public-ip show -g $hubResourceGroup -n $aksPublicIpName -o tsv --query "ipAddress")
write-host "Public IP is : $publicIp"

# Get dns fqdn
$PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$publicIp')].[id]" --output tsv)
az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv

```

### Deploy nginx Ingress controller

``` powershell
helm upgrade ingress-nginx ingress-nginx/ingress-nginx `
  --install `
  --create-namespace `
  --namespace ingress-controller `
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"=$hubResourceGroup `
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz `
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"=$aksPublicIpDnsLabel `
  --set controller.service.loadBalancerIP=$publicIp

```

## Deploy Test application

### Deploy application

``` powershell
kubectl create namespace application-test
kubectl label namespace application-test cert-manager.io/disable-validation=true
kubectl apply -f cloud\azure\resources\aks\aks-helloworld-one.yaml --namespace application-test
kubectl apply -f cloud\azure\resources\aks\aks-helloworld-two.yaml --namespace application-test

```

### Deploy Ingress rule for application

1. For Http

    ``` powershell
    kubectl apply -f .\cloud\azure\resources\aks\ingress.yaml --namespace application-test

    ```

2. For Https

    ``` powershell
    kubectl apply -f .\cloud\azure\resources\aks\ingress-ssl.yaml --namespace application-test

    ```
