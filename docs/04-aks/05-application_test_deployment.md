---
layout: default
title: Deploy test application
parent: AKS
nav_order: 5
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

## Sanity check cluster creation

1. Deploy test application

    ```powershell

    kubectl apply -f .\resources\aks\application_samples.yml

    kubectl get pods

    kubectl get service azure-vote-front --watch

    ```

1. Check application access

    <https://inventory.francecentral.cloudapp.azure.com/hello-world-one/>{:target="_blank"}

1. Remove test application

    ```powershell
    kubectl delete -f .\aks\resources\application_samples.yml

    ```
