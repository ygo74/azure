---
layout: default
title: Create Cluster
parent: AKS
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

## Create Cluster

## Init Credential

```powershell
az aks get-credentials --resource-group $azResourceGroup.ResourceGroupName --name $inventoryVars.aks.cluster_name

kubectl get nodes

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml
kubectl proxy
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

```
