---
layout: default
title: AKS
nav_order: 5
has_children: true
---

## Goals

Deploy AKS following several methods / best practices described on the Microsoft learn website with several technologies.

## Deployment status

### Automatic deployment

Azure DevOps pipeline : [![Build Status](https://dev.azure.com/ygo74/iac/_apis/build/status%2FaksBootsrap%20-%20Deployment?branchName=master)](https://dev.azure.com/ygo74/iac/_build/latest?definitionId=30&branchName=master)

### Manual deployment

{% tabs AKSdeployment %}

{% tab AKSdeployment Ansible %}

``` bash
cd .\cloud\azure\ansible
# Mount azure credentials
docker run --rm -it -v C:\Users\Administrator\azure_config_ansible.cfg:/root/.azure/credentials -v "$(Get-Location):/myapp:rw" -w /myapp local/ansible bash

# Use environment file
docker run --rm -it --env-file C:\Users\Administrator\azure_credentials  -v "$(Get-Location)/ansible:/ansible:rw" -v "$(Get-Location)/inventory:/inventory:rw" -w /ansible local/ansible bash

# Create cluster
ansible-playbook aks_cluster_create.yml -i /inventory/root/

# Assign permission : need User Managed identities principal id before
ansible-playbook aks_cluster_permissions_assign.yml -i /inventory/root/

# Configure cluster
ansible-playbook aks_cluster_configure.yml -i /inventory/root/
```

{% endtab %}
{% tab AKSdeployment Powershell %}

``` powershell
cd .\cloud\azure\powershell

& .\scripts\aks\01-Deploy-AKS.ps1  
```

{% endtab %}
{% endtabs %}

## Sources

* <https://learn.microsoft.com/fr-fr/azure/architecture/reference-architectures/containers/aks/baseline-aks>
* <https://github.com/mspnp/aks-baseline>
* <https://github.com/mspnp/aks-fabrikam-dronedelivery>
* <https://stacksimplify.com/azure-aks/azure-kubernetes-service-introduction/>
* <https://learn.microsoft.com/fr-fr/azure/aks/operator-best-practices-storage>
* <https://learn.microsoft.com/fr-fr/azure/aks/azure-csi-disk-storage-provision#dynamically-provision-a-volume>
