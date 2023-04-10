---
layout: default
title: Resource groups
parent: Deploy root resources
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

## Resources groups list definition

Resources groups are defined in a dedicated file saved into the inventory all subfolder : **_<https://github.com/ygo74/azure/blob/master/inventory/root/group_vars/all/resources_groups.yml>_**

All resoures groups are defined under the key **all_resources_groups**

1. Resources group definition

    | attribute | mandatory | comment |
    |:--------- |:--------- |:------- |
    | name      | Yes       | Resource group name |
    | location  | No        | Region where the resource group is deployed.<br />if attribute is not defined, resource group is created in the **_default location_** defined by the variable **_default_location_** |
    | tags      | No        | list of tags defined with a dictionary of string:string pairs to assign as metadata to the object |
    | state     | No        | Assert the state of the resource group. Use present to create or update and absent to delete<br>if attribute is not defined, default value is "present" |

2. File Sample

    ``` yaml
    all_resources_groups:
      - name: rg-francecentral-networking-hub
        tags:
          scope: bootstrap
      - name: rg-francecentral-storage-shared
        tags:
          scope: bootstrap
      - name: rg-aks-bootstrap-networking-spoke
        tags:
          scope: bootstrap
      - name: rg-aks-bootstrap-cluster-nodes
        state: absent
        tags:
          scope: bootstrap

    ```

## Resources groups deployment

### Ansible

``` bash
# Mount docker with ansible playbook and inventory
docker run --rm -it --env-file C:\Users\Administrator\azure_credentials  -v "$(Get-Location)/ansible:/ansible:rw" -v "$(Get-Location)/inventory:/inventory:rw" -w /ansible local/ansible bash

# Deploy resource groups
ansible-playbook root_deploy_resources_groups.yml -i /inventory/root

```
