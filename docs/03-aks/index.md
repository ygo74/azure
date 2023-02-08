---
layout: default
title: AKS
nav_order: 5
has_children: true
---

# Azure Kubernetes Services : AKS

https://learn.microsoft.com/fr-fr/azure/architecture/reference-architectures/containers/aks/baseline-aks
https://github.com/mspnp/aks-baseline
https://github.com/mspnp/aks-fabrikam-dronedelivery


## Deploy with Ansible

```bash
ansible\aks_create_cluster.yml  
```

```bash
 docker run --rm -it -v C:\Users\Administrator\azure_config_ansible.cfg:/root/.azure/credentials -v D:\devel\github\devops-toolbox\cloud\azure:/myapp:rw -w /myapp local/ansible bash
cd aks/ansible/
ansible-playbook create_cluster.yml -i /myapp/ansible
```


## Deploy with Powershell

```powershell
cloud\azure\aks\powershell\01-Deploy-AKS.ps1  
```
