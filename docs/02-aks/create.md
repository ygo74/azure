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
az aks get-credentials --resource-group $azResourceGroup.ResourceGroupName `
                       --name $inventoryVars.aks.cluster_name

kubectl get nodes

```

## Dashboard access

1. Azure dashboard

    ```powershell

    az aks browse --name MyManagedCluster --resource-group MyResourceGroup
    ```

2. Standard Kubernetes dashboard

    ```powershell
    # Install standard Kubernetes dashboard
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml

    # Enable from local Uri
    kubectl proxy

    ```

  Dashboard uri : <http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/>