---
layout: default
title: acr commands
parent: ACR
nav_order: 3
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

## List repository tags

``` powershell

$RepositoryTags = az acr repository show-tags --name $AzureRegistryName --repository $RepositoryName --output tsv --orderby time_desc
```