---
layout: default
title: Networks commands
parent: Base objects commands
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

## Virtual network

### Create virtual network

{% tabs createVnet %}

{% tab createVnet Azure-Cli %}

Source : <https://learn.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az-network-vnet-create>{:target="_blank"}

``` powershell
$aksresourceGroup     = "rg-aks-bootstrap-networking-spoke"
$vnetAddressprefix    = "10.240.0.0/16"
$vnetName             = "vnet-spoke"
az network vnet create  `
   --name $vnetName `
   --resource-group $aksresourceGroup `
   --address-prefixes $vnetAddressprefix 
```

{% endtab %}
{% tab createVnet Ansible %}

Source : <https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_virtualnetwork_module.html>{:target="_blank"}

{% raw %}
``` yaml
- name: Create virtual network
  azure.azcollection.azure_rm_virtualnetwork:
    resource_group:   '{{ _virtual_network.resource_group }}'
    name:             '{{ _virtual_network.name }}'
    address_prefixes: '{{ _virtual_network.address_prefixes }}'
    tags:             '{{ _virtual_network.tags  | default(omit) }}'
    state:            '{{ _virtual_network.state | default("present") }}'
  vars:
    _virtual_network:
      resource_group:   "rg-aks-bootstrap-networking-spoke"
      name:             "vnet-spoke"
      address_prefixes: "10.240.0.0/16"   
```
{% endraw %}
{% endtab %}
{% endtabs %}

### Get virtual network info

{% tabs getVnet %}
{% tab getVnet Azure-Cli %}

Source : <https://learn.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az-network-vnet-show>{:target="_blank"}

``` powershell
$aksresourceGroup    = "rg-aks-bootstrap-networking-spoke"
$vnetName            = "vnet-spoke"

az network vnet show -g $aksresourceGroup -n $vnetName --query "id" -o tsv

```

{% endtab %}
{% tab getVnet Ansible %}

Source : <https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_virtualnetwork_info_module.html#ansible-collections-azure-azcollection-azure-rm-virtualnetwork-info-module>{:target="_blank"}

{% raw %}

``` yaml
- name: Get Virtual Network info
  azure.azcollection.azure_rm_virtualnetwork_info:
    resource_group:   '{{ _virtual_network.resource_group }}'
    name:             '{{ _virtual_network.name }}'
  register: __virtual_network_info
  vars:
    _virtual_network:
      resource_group:   "rg-aks-bootstrap-networking-spoke"
      name:             "vnet-spoke"
```

{% endraw %}
{% endtab %}
{% endtabs %}

### Create virtual network peering

{% tabs vnetPeering %}
{% tab vnetPeering Azure-Cli %}

Source : <https://learn.microsoft.com/fr-fr/cli/azure/network/vnet/peering?view=azure-cli-latest#az-network-vnet-peering-create>{:target="_blank"}

{: .warning-title }
> Command error
>
> Unable to create peering with az cli !!!


``` powershell
$aksresourceGroup    = "rg-aks-bootstrap-networking-spoke"
$vnetName            = "vnet-spoke"
$vnetHubName         = "vnet-hub"
$hubResourceGroup    = "rg-francecentral-networking-hub"

az network vnet peering create --name np-to-vnet-hub --vnet-name $vnetName --remote-vnet $vnetHubName  --resource-group $aksresourceGroup --allow-vnet-access --allow-forwarded-traffic 

```

{% endtab %}
{% tab vnetPeering Ansible %}

Source : <https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_virtualnetworkpeering_module.html#ansible-collections-azure-azcollection-azure-rm-virtualnetworkpeering-module>{:target="_blank"}

{% raw %}

``` yaml
- name: Create virtual network_peering
  azure.azcollection.azure_rm_virtualnetworkpeering:
    name:                         'np-to-{{ _virtual_network_peering.target.name }}'
    resource_group:               '{{  _virtual_network_peering.source.resource_group }}'
    virtual_network:              '{{  _virtual_network_peering.source.name }}'
    allow_virtual_network_access: '{{  _virtual_network_peering.allow_virtual_network_access | default(false) }}'
    allow_forwarded_traffic:      '{{  _virtual_network_peering.allow_forwarded_traffic | default(false) }}'
    remote_virtual_network:
      resource_group: '{{ _virtual_network_peering.target.resource_group }}'
      name:           '{{ _virtual_network_peering.target.name }}'
  vars:
    _virtual_network_peering:
      allow_virtual_network_access: true
      allow_forwarded_traffic: true
      source:
        name:           'vnet-hub'
        resource_group: 'rg-francecentral-networking-hub'
      target:
        name:           'rg-aks-bootstrap-networking-spoke'
        resource_group: 'vnet-spoke'
  
```

{% endraw %}
{% endtab %}
{% endtabs %}

## Subnet

### Create subnet

{% tabs createSubnet %}
{% tab createSubnet Azure-Cli %}

Source : <https://learn.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-create>{:target="_blank"}

``` powershell
$resourceGroup       = "rg-aks-bootstrap-networking-spoke"
$vnetName            = "vnet-spoke"
$subnetName          = "net-cluster-nodes"
$subnetAddressprefix = "10.240.0.0/22"

az network vnet subnet create `
    -g $resourceGroup `
    --vnet-name $vnetName `
    -n $subnetName `
    --address-prefixes $subnetAddressprefix

```

{% endtab %}
{% tab createSubnet Ansible %}

Source : <https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_subnet_module.html>{:target="_blank"}

{% raw %}

``` yaml
- name: Create Subnet
  azure.azcollection.azure_rm_subnet:
    resource_group:  '{{ _virtual_network.resource_group }}'
    name:            '{{ _subnet.name }}'
    address_prefix:  '{{ _subnet.address_prefix }}'
    virtual_network: '{{ _virtual_network.name }}'
    state:           '{{ _subnet.state | default("present") }}'
  vars:
    _virtual_network:
      resource_group: 'rg-aks-bootstrap-networking-spoke'
      name:           'vnet-spoke' 
    _subnet:
      name:           'net-cluster-nodes'
      address_prefix: '10.240.0.0/22'

```

{% endraw %}
{% endtab %}
{% endtabs %}

### List subnet

{% tabs listSubnet %}
{% tab listSubnet Azure-Cli %}

Source : <https://learn.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-list>{:target="_blank"}

``` powershell
$resourceGroup     = "rg-aks-bootstrap-networking-spoke"
$vnetName          = "vnet-spoke"

az network vnet subnet list -g $resourceGroup --vnet-name $vnetName

```

{% endtab %}
{% tab listSubnet Azure-Cli %}

Source : <https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_subnet_info_module.html>{:target="_blank"}

{% raw %}

``` yaml
- name: List all subnet in virtual networks
  azure.azcollection.azure_rm_subnet_info:
    resource_group:       '{{ _virtual_network.resource_group }}'
    virtual_network_name: '{{ _virtual_network.name }}'
  vars:
    _virtual_network:
      resource_group: 'rg-aks-bootstrap-networking-spoke'
      name:           'vnet-spoke' 

```

{% endraw %}
{% endtab %}
{% endtabs %}

### Get subnet info

{% tabs subnetInfo %}
{% tab subnetInfo Azure-Cli %}

Source : <https://learn.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show>{:target="_blank"}

``` powershell
$resourceGroup       = "rg-aks-bootstrap-networking-spoke"
$vnetName            = "vnet-spoke"
$subnetName          = "net-cluster-nodes"

az network vnet subnet show -g $aksresourceGroup --vnet-name $vnetName -n $nodesSubnetName --query "id" -o tsv

```

{% endtab %}
{% tab subnetInfo Ansible %}

Source : <https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_subnet_info_module.html>{:target="_blank"}

{% raw %}

``` yaml
- name: Get subnet info
  azure.azcollection.azure_rm_subnet_info:
    resource_group:       '{{ _virtual_network.resource_group }}'
    virtual_network_name: '{{ _virtual_network.name }}'
    name:                 '{{ _subnet_name }}'
  vars:
    _virtual_network:
      resource_group: 'rg-aks-bootstrap-networking-spoke'
      name:           'vnet-spoke'
    _subnet_name:     'net-cluster-nodes'

```

{% endraw %}
{% endtab %}
{% endtabs %}

### Get available ip

{% tabs availableIp %}
{% tab availableIp Azure-Cli %}

Source : <https://learn.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-list-available-ips>{:target="_blank"}

``` powershell
$resourceGroup       = "rg-aks-bootstrap-networking-spoke"
$vnetName            = "vnet-spoke"
$subnetName          = "net-cluster-nodes"

az network vnet subnet list-available-ips --resource-group $aksresourceGroup --vnet-name $vnetName -n $nodesSubnetName

```

{% endtab %}
{% tab availableIp Ansible %}

{: .information-title }
> Get Available IP are not implemented with ansible module
>
> It seems that no ansible module exist to retrieve available IP.

{% endtab %}
{% endtabs %}
