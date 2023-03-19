---
layout: default
title: Network Management
nav_order: 3
has_children: true
---


## Sources

* <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/hub-spoke-network-topology>
* <https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli>

## Synopsis

Deploy the hub part of this reference architecture :

* Resource group for hub components
* Dedicated Virtual Network and subnet

    * Virtual network **rg-francecentral-networking-hub** with address prefixes **10.200.0.0/24**

    * Subnets

        * Subnet **firewall-subnet** with address prefixes **10.200.0.0/26**
        * Subnet **gateway-subnet** with address prefixes **10.200.0.64/27**
        * Subnet **bastion-subnet** with address prefixes **10.200.0.128/26**

## Deployments scripts

### Ansible playbook

``` bash
# Create all hub virtual networks
ansible-playbook virtual_networks_create_hub.yml -i inventory/

```
