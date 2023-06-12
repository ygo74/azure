---
layout: default
title: Configure Cluster
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

## Prerequisites

- ✅ [ACR deployed](../03-acr/index.md)
- ✅ [Hands on lab Variables loaded](01-prerequisites.md#variables-declaration-for-hands-on-lab-scripts)
- ✅ [AKS deployed](./03-create.md)

## Standard Kubernetes dashboard

``` powershell
# Deploy standard kubernetes dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

```

{: .important-title }
> Access to the standard dashboard
>
> - Execute : kubectl proxy
> - Go to dashboard <http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/>{:target="_blank"}

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

### Add ingress-nginx repo

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
