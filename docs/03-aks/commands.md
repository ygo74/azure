---
layout: default
title: aks commands
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

# Dashboard access
{: .text-blue-300 }

``` powershell
$aksName       = "aksbootstrap"
$resourceGroup = "rg-aks-bootstrap-networking-spoke"

az aks browse --name $aksName --resource-group $resourceGroup
```
