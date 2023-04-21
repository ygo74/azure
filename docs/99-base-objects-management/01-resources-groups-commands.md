---
layout: default
title: Resource groups commands
parent: Base objects commands
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

## Create resource group

{% tabs createResourceGroup %}

{% tab createResourceGroup Azure-Cli %}

Source : <https://learn.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az-group-create>{:target="_blank"}

``` powershell
$resourceGroup = "rg-francecentral-networking-hub"
$Location = "francecentral"

# Create Resource Group
az group create --name $resourceGroup --location $Location

```

{% endtab %}

{% tab createResourceGroup Ansible %}

Source : <https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_resourcegroup_module.html>{:target="_blank"}

{% raw %}
``` yaml
- name: "Deploy resources groups - Create or remove resource group"
  azure.azcollection.azure_rm_resourcegroup:
    name:     '{{ _resources_group.name }}'
    location: '{{ _resources_group.name.location | default(default_location) }}'
    tags:     '{{ _resources_group.name.tags     | default(omit) }}'
    state:    '{{ _resources_group.state         | default("present") }}'

  vars:
    _resources_group:
      name:     "rg-francecentral-networking-hub"
      location: "francecentral"

```
{% endraw %}

{% endtab %}
{% endtabs %}

