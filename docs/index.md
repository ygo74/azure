---
layout: default
title: Overview
nav_order: 1
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

## Goals

This repository has 3 mainly goals :

- Deploy AKS cluster and postgresql to host the [Dynamic Inventory Application](https://ygo74.github.io/Inventory.API/)
- Configure an Azure recipient to deploy resources from the Dynamic Inventory 
- Provide a set of guide lines, automation scripts to configure Azure resources.

Used tools in this repository are :

- [Ansible](00-prerequisites/ansible.md)
- [az-cli](00-prerequisites/azure-cli.md)
- [az powershell module](00-prerequisites/powershell-az.md)
- Azure devops pipeline

## Sources

- Hub-sopke network topology : <https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke?tabs=cli>
- Azure limits : <https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits>
- Inventory API : <https://ygo74.github.io/Inventory.API/>

## Concepts

Start the Azure's journey by following Microsoft architecture recommendations with the usage of hub/spoke patterns and by segregating permissions granted to automation services accounts:

- Create Root user of Azure subscription : This account is responsible to create the resources groups for expected deployments, provision automation accounts, grant them on their respective resource and manage the Hub virtual networks

- Bootstrap Azure subscription : Deploy the [inventory application](https://ygo74.github.io/Inventory.API/) to manage Azure inventory which is the brain of automation scripts.

- Standard Automation users : These accounts are used to deploy their resources inside their resources groups.

## Resources naming convention

Majority of resources have their name which starts with the first letter of resource name's words. the "-" is used to split terms in the naming if it is allowed by the Azure's APIs.

Some exceptions exist:

- Internal decision for short resource'name or because they are part of terms generaly used.
- Azure API rule

| Resource kind             | prefix | Specific naming rule           |
|:------------------------- |:------ |:------------------------------ |
| Resource group            | rg-    | N/A                            |
| Virtual network           | vnet-  | Yes, internal decision         |
| Subnet                    | net-   | Yes, internal decision         |
| Azure Kubernetes services | aks-   | N/A                            |
| Azure Container registry  | acr    | Yes. ....                      |
| Storage account           | sa     | Yes, Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only Storage account must be unique|
| Disk                      | disk-  | Yes, internal decision         |
| User Managed Identity     | umi-   | N/A                            |
