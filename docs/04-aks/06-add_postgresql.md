---
layout: default
title: Deploy postgresql
parent: AKS
nav_order: 6
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

## Disk

``` powershell
# Get disk id
$aksPostgresDiskId = az disk show -n $aksPostgresqlDisk -g $aksStorageResourceGroup --query id --output tsv
if ($null -eq $aksPostgresDiskId) { throw "Unable to retrieve Disk $aksPostgresqlDisk Id"}
write-host "Postgresql disk ID : $aksPostgresDiskId"

# Create persistent volume
(Get-Content .\resources\aks\volumes\disks\postgresql-disk-pv.yml -Raw) `
  -replace "\`${POSTGRESQL_DISK_ID}", $aksPostgresDiskId `
  | kubectl apply -f -

# Create persistent volume Claim
 kubectl apply -f .\resources\aks\volumes\disks\postgresql-disk-pvc.yml

# Check disk bind status
# $diskBindStatus = kubectl get pvc -o jsonpath="{.items[*].status.phase}"
$diskBindStatus = kubectl get pvc pvc-postgresql-dyninv -n default -o jsonpath="{.status.phase}" -wait
if ($diskBindStatus -ne "Bound") { throw "Unable to bind Disk $aksPostgresqlDisk"}
write-host "Postgresql disk bind status : $diskBindStatus"

```

## Create and use a volume with Azure Files in Azure Kubernetes Service (AKS) 

### Create a storage account

{: .warning-title }
> Storage account
>
> Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only
> Storage account must be unique

``` powershell
# Get aks nodes resources group

# $aksNodesResourceGroup = $(az aks show --resource-group $aksresourceGroup --name $aksName --query nodeResourceGroup -o tsv)
# write-host "Node resources group is : $aksNodesResourceGroup"

# Create the storage account
az storage account create -n $aksStorageName -g $aksStorageResourceGroup -l $aksLocation --sku Standard_LRS

```

### Create a storage share

``` powershell
# Get storage connection string
$storageConnectionString = $(az storage account show-connection-string -n $aksStorageName -g $aksStorageResourceGroup -o tsv)
write-host "Storage connection string is : $storageConnectionString"

# Create the storage share
az storage share create -n postgresql-aksbootstrap --connection-string $storageConnectionString

# get the storage key
$storageKey = $(az storage account keys list --resource-group $aksStorageResourceGroup --account-name $aksStorageName --query "[0].value" -o tsv)
write-host "Storage Key is : $storageKey"

```

### Create a Kubernetes secret

``` powershell
# Create secret key
kubectl create secret generic secret-storage-bootstrap --from-literal=azurestorageaccountname=$aksStorageName --from-literal=azurestorageaccountkey=$storageKey

```

### Create a persistent volume

``` powershell
kubectl create -f .\cloud\azure\resources\aks\volumes\persistent-volume.yml
kubectl create -f .\cloud\azure\resources\aks\volumes\persistent-volume-claim.yml
kubectl get pvc pv-postgresql
```

## Deploy Postgresql with helm

``` powershell
# Add bitmani repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade postgresql bitnami/postgresql `
  --install `
  --namespace postgresql `
  --set primary.persistence.existingClaim=pvc-postgresql-dyninv `
  --set volumePermissions.enabled=true 

$postgres_password_base64=$(kubectl get secret --namespace default postgresql -o jsonpath="{.data.postgres-password}")
$postgres_password=[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($postgres_password_base64))  

kubectl run postgresql-client --rm --tty -i --restart='Never' --namespace postgresql --image docker.io/bitnami/postgresql:15.2.0-debian-11-r16 --env="PGPASSWORD=$postgres_password" `
      --command -- psql --host postgresql -U postgres -d postgres -p 5432
```

``` powershell
helm upgrade postgresql2 bitnami/postgresql `
  --install `
  --namespace default `
  --set primary.persistence.existingClaim=azure-managed-disk `
  --set volumePermissions.enabled=true `
  --set global.postgresql.auth.postgresPassword=123456789

```

## Ansible Role: PostgreSQL

* <https://github.com/geerlingguy/ansible-role-postgresql>

Installs and configures PostgreSQL server on RHEL/CentOS or Debian/Ubuntu servers.
