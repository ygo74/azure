---
layout: default
title: Deploy test application
parent: AKS
nav_order: 4
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
{: .text-blue-300 }

1. Deploy test application

    ```powershell

    kubectl apply -f .\resources\aks\application_samples.yml

    kubectl get pods

    kubectl get service azure-vote-front --watch

    ```

2. Remove test application

    ```powershell
    kubectl delete -f .\aks\resources\application_samples.yml

    ```
