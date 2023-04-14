---
layout: default
title: Update an existing Cluster
parent: AKS
nav_order: 4
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
- ✅ [AKS deployed](./03-create.md)
- ✅ [Hands on lab Variables loaded](01-prerequisites.md#variables-declaration-for-hands-on-lab-scripts)
- ✅ [Resources groups deployed](./01-prerequisites.md#resources-groups)
- ✅ [Virtual network deployed](./01-prerequisites.md#virtual-network)
- ✅ [User Managed Identities deployed](./01-prerequisites.md#user-managed-identities)

## Update AKS Cluster to Use User Managed Identities

If Cluster has been created with Ansible (which doesn't support User Managed Identities), It is mandatory to update the cluster to use the User Managed identities.

### Grant aks Control Plane Identity to cluster nodes resources group

:point_right: **Hands-on lab**
{: .text-blue-100 }

1. Get Control plane and Kubelet identities

  ```powershell
  # Get Control Plane identity
  $aksControlPlaneIdentityPrincipalId =$(az identity show --name $aksControlPlaneIdentity --resource-group $managedIdentitiesResourceGroup --query "principalId" -o tsv)
  write-host "Aks Control Plane identity Principal Id : $aksControlPlaneIdentityPrincipalId"

  # Get kubelet identity
  $aksKubeletIdentityPrincipalId =$(az identity show --name $aksKubeletIdentity --resource-group $managedIdentitiesResourceGroup --query "principalId" -o tsv)
  write-host "Aks Kubelet identity Principal Id : $aksKubeletIdentityPrincipalId"

  ```

1. Grant Control Plane Identity on nodes resource group

    ``` powershell
    # Get aks nodes resource group Id
    $aksNodesResourceGroupId = $(az group show -n $aksNodesResourceGroup --query "id" -o tsv)
    if ($null -eq $aksNodesResourceGroupId) { throw "Unable to retrieve aks nodes resource group $aksNodesResourceGroup Id"}
    write-host "Aks nodes Resource group Id : $aksNodesResourceGroupId"

    # Assign contributor to AKS Identity on resource group Hub
    az role assignment list --scope $aksNodesResourceGroupId
    az role assignment create --assignee $aksControlPlaneIdentityPrincipalId --scope $aksNodesResourceGroupId --role "Contributor"

    ```

1. Grant Kubelet Identity on Kubelet resource

    ``` powershell
    # Get Kubelet resource ID
    $aksKubeletResourceId = $(az aks show -g $aksresourceGroup -n $aksName --query "identityProfile.kubeletidentity.resourceId" -o tsv)
    if ($null -eq $aksKubeletResourceId) { throw "Unable to retrieve kubelet resource Id on aks cluster $aksName"}
    write-host "Aks Kubelet Resource Id : $aksKubeletResourceId"

    # Assign Managed Identity Operator to kubelet Identity on Kubelet resource id
    az role assignment list --scope $aksKubeletResourceId
    az role assignment create --assignee $aksKubeletIdentityPrincipalId --scope $aksKubeletResourceId --role "Managed Identity Operator"

    ```

### Update cluster with Identities

1. Get Identities Id

    ``` powershell
    # Get Control plane Identity Id
    $aksControlPlaneIdentityId =$(az identity show --name $aksControlPlaneIdentity --resource-group $managedIdentitiesResourceGroup --query "id" -o tsv)
    write-host "Aks Control Plane identity Principal Id : $aksControlPlaneIdentityId"

    # Get kubelet identity Id
    $aksKubeletIdentityId =$(az identity show --name $aksKubeletIdentity --resource-group $managedIdentitiesResourceGroup --query "id" -o tsv)
    write-host "Aks Control Plane identity Principal Id : $aksKubeletIdentityId"

    ```

1. Update AKS CLuster

    ``` powershell
    az aks update `
        --resource-group $aksresourceGroup `
        --name $aksName `
        --enable-managed-identity `
        --assign-identity $aksControlPlaneIdentityId `
        --assign-kubelet-identity $aksKubeletIdentityId `
        --yes
    ```

1. Upgrade node pool to use the new Kubelet Identity

    ``` powershell
    az aks nodepool upgrade --cluster-name $aksName --resource-group $aksresourceGroup --name default --node-image-only
    ``` powershell

1. Attach to ACR

    ``` powershell
    az aks update --name $aksName --resource-group $aksresourceGroup `
                  --attach-acr $acrName
                  
    ``` powershell

### Attach ACR and enable managed identity

{: .warning-title }
> Deployment location
>
> ACR and AKS should be in the same location

``` powershell
# Attach using acr-name
az aks update -n $aksName -g $aksresourceGroup  --attach-acr $acrName --enable-managed-identity

# Check if ACR access is well configured
az aks check-acr --resource-group $aksresourceGroup --name $aksName --acr $acrName

```

## Sources

https://learn.microsoft.com/en-us/azure/aks/start-stop-cluster?tabs=azure-cli#stop-an-aks-cluster