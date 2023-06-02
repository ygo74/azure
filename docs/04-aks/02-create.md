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

- ✅ [ACR deployed](../03-acr/index.md)
- ✅ [Hands on lab Variables loaded](01-prerequisites.md#variables-declaration-for-hands-on-lab-scripts)
- ✅ [Resources groups deployed](./01-prerequisites.md#resources-groups)
- ✅ [Virtual network deployed](./01-prerequisites.md#virtual-network)
- ✅ [User Managed Identities deployed](./01-prerequisites.md#user-managed-identities)

## Cluster identity

To access others resources, AKS Cluster requires either a Service principal or a managed identity. Managed Identities are the recommended way mainly because the don't need to manage the password.

Managed identities can be either system managed identities or user managed identities.

{: .note-title }
> No Hands-on lab for Service principal
>
> There is no interest to show a sample with service principal in the AKS section because requirements for permissions will be viewed with User Managed identity.
> A service principal and a User managed identity must be created and theirs permissions applied on the same resources before the AKS provisioning.

### Identity type decision criteria

| criteria                                   | User Managed Identity | System Managed Identity        | Service Principal |
|:------------------------------------------ | --------------------- | ------------------------------ | ----------------- |
| Password Management                        | No                    | No                             | Required          |
| Permissions to be applied                  | Yes                   | Yes                            | Yes               |
| Segregation of duties to apply permissions | Possible              | Need to break the provisioning | Possible          |
| Identity management                        | Required              | No                             | Required          |
| Supported by Azure-Cli                     | Yes                   | Yes                            | Yes               |
| Supported by Ansible azure collection      | No                    | Yes                            | Yes               |
| Provisioning time                          | Fast                  | Slow                           | Fast              |

:point_right: Comparison conclusion
{: .text-blue-300 }

- Don't use service principal to avoid password storage, usage and renewal management

- Use user Managed Identity to not give "User Access Administrator" roles on other automation accounts

- Use System Managed Identity only for Proof of Concept to have less configuration tasks

{: .warning-title }
> User Managed Identity drawback for Ansible provisioning
>
> As It is not yet supported in Ansible azure.azcollection v1.15.0 and a conflict exist between azure.azcollection v1.15.0 and Azure-cli v2.46.0[^1] :
>
> - It is mandatory to break the provisioning from Ansible
> - Use an other execution environment with only Azure-Cli
> - Wait more time during the cluster update to switch from System Managed Identity to User Managed Identity

[^1]: [Conflict between azure.azcollection v1.15.0 and Azure-cli v2.46.0](https://github.com/ansible-collections/azure/issues/1138){:target="_blank"}

## Remarks

{: .important-title }
> Configuration notes
>
> 1. Nodes resources **must not exists** when creating a new cluster
> 2. Services cidr **must not be** an existing subnet cidr
> 3. Dns service ip **must be within** the Kubernetes service address range specified in services cidr
> 4. ACR and AKS should be in the same location

## Create Aks with user managed identities

:point_right: **Hands-on lab**
{: .text-blue-100 }

1. Get Subnet and Identities Id

    ``` powershell
    # Get subnet id
    $subnetNodeId = $(az network vnet subnet show -g $aksresourceGroup --vnet-name $vnetName -n $nodesSubnetName --query "id" -o tsv)
    write-host "Subnet node Id : $subnetNodeId"

    # Get Control plane Identity Id
    $aksControlPlaneIdentityId =$(az identity show --name $aksControlPlaneIdentity --resource-group $managedIdentitiesResourceGroup --query "id" -o tsv)
    write-host "Aks Control Plane identity Principal Id : $aksControlPlaneIdentityId"

    # Get kubelet identity Id
    $aksKubeletIdentityId =$(az identity show --name $aksKubeletIdentity --resource-group $managedIdentitiesResourceGroup --query "id" -o tsv)
    write-host "Aks Control Plane identity Principal Id : $aksKubeletIdentityId"

    ```

1. Create cluster With User Managed identities

    Source : <https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create>{:target="_blank"}

{% tabs createAKS %}

{% tab createAKS Azure-Cli %}

``` powershell
az aks create `
    --resource-group $aksresourceGroup `
    --name $aksName `
    --kubernetes-version 1.24.9 `
    --node-resource-group $aksNodesResourceGroup `
    --node-count 1 `
    --generate-ssh-keys `
    --attach-acr $acrName `
    --load-balancer-sku Standard `
    --network-plugin azure `
    --vnet-subnet-id $subnetNodeId `
    --service-cidr $servicesSubnetAddressprefix `
    --dns-service-ip 10.240.4.2 `
    --enable-managed-identity `
    --assign-identity $aksControlPlaneIdentityId `
    --assign-kubelet-identity $aksKubeletIdentityId

```

{% endtab %}

{% tab createAKS Ansible %}

{: .warning-title }
> Create AKS Cluster with User Managed Identities Not Yet Supported
>
> Ansible module **azure.azcollection.azure_rm_aks** only supports System Managed Identity or Service Principal.

{% endtab %}

{% endtabs %}

## Create Aks with system managed identities

:point_right: **Hands-on lab**
{: .text-blue-100 }

### Get Resources dependencies Id

Before creating the cluster, It is mandatory to retrieve some dependencies resources id.

{% tabs createAKSMI-GetInfo %}

{% tab createAKSMI-GetInfo Azure-Cli %}

``` powershell
# Get subnet id
$subnetNodeId = $(az network vnet subnet show -g $aksresourceGroup --vnet-name $vnetName -n $nodesSubnetName --query "id" -o tsv)
write-host "Subnet node Id : $subnetNodeId"

```

{% endtab %}

{% tab createAKSMI-GetInfo Ansible %}

{% raw %}

``` yaml
# Retrieve subnet info to retrieve its id
- name: Get facts of specific subnet
    azure.azcollection.azure_rm_subnet_info:
    resource_group:       '{{ resource_group }}'
    virtual_network_name: '{{ virtual_network_name }}'
    name:                 '{{ subnet_name }}'
    register: _subnet_info

```

{% endraw %}

{% endtab %}
{% endtabs %}

### Create cluster With System Managed identities

{% tabs createAKSMI %}

{% tab createAKSMI Azure-Cli %}

``` powershell
az aks create `
    --resource-group $aksresourceGroup `
    --name $aksName `
    --kubernetes-version 1.24.9 `
    --node-resource-group $aksNodesResourceGroup `
    --node-count 1 `
    --generate-ssh-keys `
    --attach-acr $acrName `
    --load-balancer-sku Standard `
    --network-plugin azure `
    --vnet-subnet-id $subnetNodeId `
    --service-cidr $servicesSubnetAddressprefix `
    --dns-service-ip 10.240.4.2 `
    --enable-managed-identity

```

{% endtab %}

{% tab createAKSMI Ansible %}

{% raw %}

``` yaml
- name: Create a managed Azure Container Services (AKS) cluster
    azure.azcollection.azure_rm_aks:
    name:               '{{ cluster_name }}'
    location:           '{{ location }}'
    resource_group:     '{{ resource_group }}'
    dns_prefix:         '{{ cluster_name }}'
    kubernetes_version: "{{ _aks_versions_info.azure_aks_versions[-1] }}"

    linux_profile:
      admin_username: "{{ username }}"
      ssh_key:        "{{ ssh_key }}"

    agent_pool_profiles:
        - name: default
          count: 1
          vm_size: Standard_D2_v2
          vnet_subnet_id: '{{ _subnet_info.subnets[0].id }}'
          mode: System
    node_resource_group: '{{ nodes_resource_group }}'
    enable_rbac: yes
    network_profile:
      load_balancer_sku: standard
      network_plugin: azure

    tags: '{{ cluster_tags | default({}) }}'

```

{% endraw %}
{% endtab %}
{% endtabs %}


### Apply permissions for cluster System Managed Identity

For Proof of concept, You can choose to let all resources in the cluster nodes resources groups and no permissions grant are needed.

The Hands on lab is just to show how retrieve the cluster identity to apply permission if it is required for the Proof of Concept.

:point_right: **Hands-on lab**
{: .text-blue-100 }

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

## Connect to AKS Cluster

``` powershell
# Get cluster configuration
az aks get-credentials --name $aksName --resource-group $aksresourceGroup --overwrite-existing 

# Check if access is well configured
kubectl get nodes

# Check if ACR access is well configured
az aks check-acr --resource-group $aksresourceGroup --name $aksName --acr $acrName

```

## Sources

- [Use Managed Identities](https://learn.microsoft.com/en-us/azure/aks/use-managed-identity){:target="_blank"}
- [Use Service Principal](https://learn.microsoft.com/en-us/azure/aks/kubernetes-service-principal?tabs=azure-cli){:target="_blank"}

## Notes
