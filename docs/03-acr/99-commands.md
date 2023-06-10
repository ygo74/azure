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

## Purge repositories

Sources : 

* <https://zimmergren.net/purging-container-images-from-azure-container-registry/#:~:text=az%20acr%20run%20--cmd%20%22acr%20purge%20--filter%20%27my-image%3A.%2A%27,agent%2C%20and%20upon%20availability%2C%20the%20job%20kicks%20off.>{:target="_blank"}

* <https://learn.microsoft.com/fr-fr/azure/container-registry/container-registry-auto-purge?WT.mc_id=tozimmergren&ref=zimmergren.net&utm_campaign=zimmergren&utm_medium=blog&utm_source=zimmergren>{:target="_blank"}

``` powershell
az acr run --cmd "acr purge --filter 'dynamicinventory/configuration-api:.*' --filter 'dynamicinventory/devices-api:.*' --ago 10d --untagged" --registry aksbootstrap /dev/null
```
