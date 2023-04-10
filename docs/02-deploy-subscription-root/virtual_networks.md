---
layout: default
title: Virtual Networks
parent: Deploy root resources
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

## Networks design

Deploy the Hub and spoke networking model as described in the Microsoft architecture best practices :

* <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/hub-spoke-network-topology>
* <https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli>

## Virtual networks list definition

Virtual networks are defined in a dedicated file saved into the inventory all subfolder : **_<https://github.com/ygo74/azure/blob/master/inventory/root/group_vars/all/virtual_networks.yml>_**

All virtual networks are defined under the key **all_virtual_networks**

1. Virtual networks definition

    | attribute        | mandatory | comment                                         |
    |:---------------- |:--------- |:----------------------------------------------- |
    | name             | Yes       | virtual network name                            |
    | resource_group   | Yes       | Resource group where virtual network is created |
    | address_prefixes | Yes       | Virtual network cidr                            | 
    | tags             | No        | list of tags defined with a dictionary of string:string pairs to assign as metadata to the object |
    | state            | No        | Assert the state of the virtual network. Use present to create or update and absent to delete<br>if attribute is not defined, default value is "present"          |
    | subnets          | No        | List of subnets into the virtual network  |
    | peerings         | No        | List of peerings from the virtual network |

    1.1. Subnet Definition

      | attribute        | mandatory | comment                                         |
      |:---------------- |:--------- |:----------------------------------------------- |
      | name             | Yes       | subnet name                                     |
      | address_prefixes | Yes       | subnet cidr                                     | 

    1.2. Peering Definition

      | attribute        | mandatory | comment                                         |
      |:---------------- |:--------- |:----------------------------------------------- |
      | to               | Yes       | dictionary of string:string pairs to target the remote virtual network |
      | allow_virtual_network_access | No       | Allows VMs in the remote VNet to access all VMs in the local VNet<br>if attribute is not defined, default value is false | 
      | allow_forwarded_traffic      | No       | Allows forwarded traffic from the VMs in the remote VNet<br>if attribute is not defined, default value is false |  

2. File Sample

    ``` yaml
    all_virtual_networks:
      # Hub for france central location
      - name: vnet-hub
        resource_group: rg-francecentral-networking-hub
        address_prefixes: 10.200.0.0/24
        subnets:
          - name: firewall-subnet
            address_prefix: 10.200.0.0/26
          - name: gateway-subnet
            address_prefix: 10.200.0.64/27
          - name: bastion-subnet
            address_prefix: 10.200.0.128/26
        tags:
          scope: bootstrap
          virtual_network_kind: hub

      # aks bootstrap networks
      - name: vnet-spoke
        resource_group: rg-aks-bootstrap-networking-spoke
        address_prefixes: 10.240.0.0/16
        subnets:
          - name: cluster-nodes-subnet
            address_prefix: 10.240.0.0/22
          - name: cluster-services-subnet
            address_prefix: 10.240.4.0/28
          - name: application-gateway-subnet
            address_prefix: 10.240.5.0/24
          - name: private-links-subnet
            address_prefix: 10.240.4.32/28
        peerings:
          - to:
              name: vnet-hub
              resource_group: rg-francecentral-networking-hub
            allow_virtual_network_access: true
            allow_forwarded_traffic: true
        tags:
          scope: bootstrap
          virtual_network_kind: spoke

    ```

## Virtual networks deployment

### Ansible

``` bash
# Mount docker with ansible playbook and inventory
docker run --rm -it --env-file C:\Users\Administrator\azure_credentials  -v "$(Get-Location)/ansible:/ansible:rw" -v "$(Get-Location)/inventory:/inventory:rw" -w /ansible local/ansible bash

# Deploy resource groups
ansible-playbook root_deploy_virtual_networks.yml -i /inventory/root

```
