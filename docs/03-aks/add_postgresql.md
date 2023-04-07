---
layout: default
title: Deploy postgresql
parent: AKS
nav_order: 5
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

## Sources

* <https://learn.microsoft.com/en-us/azure/aks/concepts-storage>
* <https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision>

## Create and use a volume with Azure Files in Azure Kubernetes Service (AKS) 

### Create a storage account

{: .warning-title }
> Storage account
>
> Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only
> Storage account must be unique

``` powershell
# Get aks nodes resources group
$aksNodesResourceGroup = $(az aks show --resource-group $aksresourceGroup --name $aksName --query nodeResourceGroup -o tsv)
write-host "Node resources group is : $aksNodesResourceGroup"

# Create the storage account
az storage account create -n $aksStorageName -g $aksNodesResourceGroup -l $aksLocation --sku Standard_LRS

```

### Create a storage share

``` powershell
# Get storage connection string
$storageConnectionString = $(az storage account show-connection-string -n $aksStorageName -g $aksNodesResourceGroup -o tsv)
write-host "Storage connection string is : $storageConnectionString"

# Create the storage share
az storage share create -n postgresql --connection-string $storageConnectionString

# get the storage key
$storageKey = $(az storage account keys list --resource-group $aksNodesResourceGroup --account-name $aksStorageName --query "[0].value" -o tsv)
write-host "Storage Key is : $storageKey"

```

### Create a Kubernetes secret

``` powershell
# Create secret key
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$aksStorageName --from-literal=azurestorageaccountkey=$storageKey

```

### Create a persistent volume

``` powershell
kubectl create -f .\cloud\azure\resources\aks\volumes\persistent-volume.yml
kubectl create -f .\cloud\azure\resources\aks\volumes\persistent-volume-claim.yml
kubectl get pvc azurefile
```

## Deploy Postgresql with helm

``` powershell
# Add bitmani repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade postgresql bitnami/postgresql `
  --install `
  --namespace default `
  --set persistence.existingClaim=azurefile `
  --set volumePermissions.enabled=true

$postgres_password_base64=$(kubectl get secret --namespace default postgresql -o jsonpath="{.data.postgres-password}")
$postgres_password=[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($postgres_password_base64))  

kubectl run postgresql-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:15.2.0-debian-11-r16 --env="PGPASSWORD=$POSTGRES_PASSWORD" `
      --command -- psql --host postgresql -U postgres -d postgres -p 5432
```