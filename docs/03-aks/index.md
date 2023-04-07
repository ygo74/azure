---
layout: default
title: AKS
nav_order: 5
has_children: true
---

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>


## Sources

* <https://learn.microsoft.com/fr-fr/azure/architecture/reference-architectures/containers/aks/baseline-aks>
* <https://github.com/mspnp/aks-baseline>
* <https://github.com/mspnp/aks-fabrikam-dronedelivery>
* <https://stacksimplify.com/azure-aks/azure-kubernetes-service-introduction/>

## Automatic deployment

### Deploy with ansible
{: .text-blue-200 }

``` bash
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


# Azure Kubernetes Services : AKS

``` powershell
$aksName                  = "aksbootstrap"
$aksresourceGroup         = "rg-aks-bootstrap-networking-spoke"
# $aksLocation              = "eastus"
$aksLocation              = "francecentral"
$aksPublicIpName          = "pi-inventory-gateway"
$aksPublicIpDnsLabel      = "inventory"
$aksPublicIpResourceGroup = "rg-aks-bootstrap-networking-hub"
$acrName                  = "aksbootstrap"

# Create Resource Group
az group create --name $aksresourceGroup --location $aksLocation

# Create ACR
az acr create --resource-group $aksresourceGroup --name $acrName --sku Basic --admin-enabled true
# Francecentral admin user not enabled by default
az acr login --name $acrName

# Create AKS
az aks get-versions --location $aksLocation --output table
az aks create `
    --resource-group $aksresourceGroup `
    --name $aksName `
    --node-count 2 `
    --generate-ssh-keys `
    --attach-acr $acrName

az aks get-credentials --resource-group $aksresourceGroup --name $aksName --overwrite-existing

kubectl get nodes (=> v1.24.9)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
# Dashboard uri : <http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/>

# Get AKS Node groups and identity
$aksNodeGroup=$(az aks show --resource-group $aksresourceGroup --name $aksName --query nodeResourceGroup -o tsv)
$aksNodeGroup
$aksIdentity = $(az aks show --resource-group $aksresourceGroup --name $aksName --query "identity.principalId" -o tsv)
$aksIdentity

# Ensure Aks granted to network contributor
$aksNodeGroupId = $(az group show -n $aksNodeGroup --query "id" -o tsv)
$aksNodeGroupId

az role assignment list --scope $aksNodeGroupId
az role assignment create --assignee $aksIdentity --scope $aksNodeGroupId --role "Network Contributor"
az role assignment list --scope $aksNodeGroupId


# CREATE IP
az network public-ip create --resource-group $aksNodeGroup --name $aksPublicIpName --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv
# DNS Label
az network public-ip update -g $aksNodeGroup -n $aksPublicIpName --dns-name $aksPublicIpDnsLabel --allocation-method Static
# fqdn testygo.eastus.cloudapp.azure.com
# fqdn testygo.francecentral.cloudapp.azure.com

$publicIp = $(az network public-ip show -g $aksPublicIpResourceGroup -n $aksPublicIpName -o tsv --query "ipAddress")
$publicIp

# -----------------------------------------------------------------------------------
# Deploy Application
# -----------------------------------------------------------------------------------
kubectl create namespace ingress-basic
kubectl apply -f cloud\azure\resources\aks\aks-helloworld-one.yaml --namespace ingress-basic
kubectl apply -f cloud\azure\resources\aks\aks-helloworld-two.yaml --namespace ingress-basic
# kubectl apply -f cloud\azure\resources\aks\ingress.yaml --namespace ingress-basic


# -----------------------------------------------------------------------------------
# Install ingress to use static public ip
# -----------------------------------------------------------------------------------
$NAMESPACE="ingress-basic"

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade ingress-nginx ingress-nginx/ingress-nginx `
  --install `
  --create-namespace `
  --namespace $NAMESPACE `
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-resource-group"=$aksPublicIpResourceGroup `
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz `
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"=$aksPublicIpDnsLabel `
  --set controller.service.loadBalancerIP=$publicIp

$PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$publicIp')].[id]" --output tsv)
# az network public-ip update --ids $PUBLICIPID --dns-name testygo
az network public-ip show --ids $PUBLICIPID --query "[dnsSettings.fqdn]" --output tsv

# -----------------------------------------------------------------------------------
# Deploy cert-manager
# -----------------------------------------------------------------------------------
# Label the ingress-basic namespace to disable resource validation
kubectl label namespace ingress-basic cert-manager.io/disable-validation=true

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

# Update your local Helm chart repository cache
helm repo update

# Install the cert-manager Helm chart
helm upgrade cert-manager jetstack/cert-manager `
  --install `
  --namespace ingress-basic `
  --set installCRDs=true `
  --set nodeSelector."kubernetes\.io/os"=linux

kubectl apply -f .\containers\kubernetes\configuration\cert-manager\02-cluster-issuer.yaml --namespace ingress-basic

# UPDATE BEFORE FQDN in .\cloud\azure\resources\aks\ingress-ssl.yaml 
kubectl apply -f .\cloud\azure\resources\aks\ingress-ssl.yaml --namespace ingress-basic


# -----------------------------------------------------------------------------------
# cleanup
# -----------------------------------------------------------------------------------
kubectl delete -f .\cloud\azure\resources\aks\ingress-ssl.yaml --namespace ingress-basic
kubectl delete -f .\containers\kubernetes\configuration\cert-manager\02-cluster-issuer.yaml

helm list --namespace ingress-basic
# cert-manager    cert-manager-v1.11.0    v1.11.0
# ingress-nginx   ingress-nginx-4.5.2     1.6.4

helm uninstall cert-manager ingress-nginx  --namespace ingress-basic
kubectl delete -f cloud\azure\resources\aks\aks-helloworld-one.yaml --namespace ingress-basic
kubectl delete -f cloud\azure\resources\aks\aks-helloworld-two.yaml --namespace ingress-basic

kubectl delete namespace ingress-basic

az group delete --name $aksresourceGroup

# -----------------------------------------------------------------------------------
# debug
# -----------------------------------------------------------------------------------
kubectl get certificate --namespace ingress-basic
kubectl describe certificate  tls-secret  --namespace ingress-basic

kubectl get orders -A
kubectl describe order tls-secret-qpflt-2756220252 -n ingress-basic
kubectl describe challenge tls-secret-qpflt-2756220252-2493209797 -n ingress-basic
Reason:      Waiting for HTTP-01 challenge propagation: did not get expected response when querying endpoint, expected "s2PdyetI1DoBwvSMC7plrnWhfHKqRIJITmB3BPJG8PI.qlDBuMT9NFjbO3jZv_iL5uoU-L8Wa83fFqQfZSgZSyA" but got:

```