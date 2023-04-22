---
layout: default
title: Storages
parent: Deploy root resources
nav_order: 3
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

## storage list definition

Storages are defined in a dedicated file saved into the inventory all subfolder : **_<https://github.com/ygo74/azure/blob/master/inventory/root/group_vars/all/storages.yml>_**{:target="_blank"}

All storages are defined under the key **all_storage_accounts**

1. Storage definition

    | attribute        | mandatory | comment                                         |
    |:---------------- |:--------- |:----------------------------------------------- |
    | name             | Yes       | Storage account name                            |
    | resource_group   | Yes       | Resource group where storage account is created |
    | sku              | Yes       | sku                            | 
    | kind             | Yes       | Storage kind |
    | state            | No        | Assert the state of the storage account. Use present to create or update and absent to delete<br>if attribute is not defined, default value is "present"          |
    | public_network_access | No        | Allow or disallow public network access to Storage Account<br>if attribute is not defined, default value is true  |
    | shares           | No        | List of file shares defined in the storage account |
    | tags             | No        | list of tags defined with a dictionary of string:string pairs to assign as metadata to the object |

    1.1. Share Definition

      | attribute        | mandatory | comment                                         |
      |:---------------- |:--------- |:----------------------------------------------- |
      | name             | Yes       | share name                                      |
      | quota            | Yes       | Max size in gigabytes allowed for the share.    | 

2. File Sample

    ``` yaml
    all_storage_accounts:

      - name:                  staygo74bootstrap
        resource_group:        rg-francecentral-storage-shared
        sku:                   Standard_LRS
        kind:                  StorageV2
        public_network_access: true
        tags:
          scope: bootstrap

        shares:
          - name: postgresql-aksbootstrap
            quota: 5
    ```

## Storage deployment

### Ansible

``` bash
# Mount docker with ansible playbook and inventory
docker run --rm -it --env-file C:\Users\Administrator\azure_credentials  -v "$(Get-Location)/ansible:/ansible:rw" -v "$(Get-Location)/inventory:/inventory:rw" -w /ansible local/ansible bash

# Deploy resource groups
ansible-playbook root_deploy_storage.yml -i /inventory/root

```
