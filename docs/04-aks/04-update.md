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

|                                                                                                     |     |
|:--------------------------------------------------------------------------------------------------- | --- |
| [ACR deployed](../03-acr/index.md)                                                                  | ✅ |
| [Hands on lab Variables loaded](02-prerequisites.md#variables-declaration-for-hands-on-lab-scripts) | ✅ |
| [AKS deployed](./03-create.md)                                                                      | ✅ |

### Update AKS Cluster

1. Grant Control PlaneIdentity on nodes resource group

    ``` powershell
    # Get aks nodes resource group Id
    $aksNodesResourceGroupId = $(az group show -n $aksNodesResourceGroup --query "id" -o tsv)
    if ($null -eq $aksNodesResourceGroupId) { throw "Unable to retrieve aks nodes resource group $aksNodesResourceGroup Id"}
    write-host "Aks nodes Resource group Id : $aksNodesResourceGroupId"

    # Assign contributor to AKS Identity on resource group Hub
    az role assignment list --scope $aksNodesResourceGroupId
    az role assignment create --assignee $aksControlPlaneIdentityPrincipalId --scope $aksNodesResourceGroupId --role "Contributor"

    # Get Kubelet resource ID
    $aksKubeletResourceId = $(az aks show -g $aksresourceGroup -n $aksName --query "identityProfile.kubeletidentity.resourceId" -o tsv)
    if ($null -eq $aksKubeletResourceId) { throw "Unable to retrieve kubelet resource Id on aks cluster $aksName"}
    write-host "Aks Kubelet Resource Id : $aksKubeletResourceId"

    # Assign Managed Identity Operator to kubelet Identity on Kubelet resource id
    az role assignment list --scope $aksKubeletResourceId
    az role assignment create --assignee $aksKubeletIdentityPrincipalId --scope $aksKubeletResourceId --role "Managed Identity Operator"

    ```

2. Update AKS CLuster

    ``` powershell
    az aks update `
        --resource-group $aksresourceGroup `
        --name $aksName `
        --enable-managed-identity `
        --attach-acr $acrName `
        --assign-identity $aksControlPlaneIdentityId `
        --assign-kubelet-identity $aksKubeletIdentityId
    ```

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
