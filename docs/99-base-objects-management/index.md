---
layout: default
title: Network Management
nav_order: 7
has_children: true
---


## Deployments scripts

### Ansible playbook

``` bash
# Create all hub virtual networks
ansible-playbook virtual_networks_create_hub.yml -i inventory/

```
