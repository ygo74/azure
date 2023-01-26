---
layout: default
title: ACR
nav_order: 4
has_children: true
---

Goal : Docker image repository

## Sources
{: .text-blue-300 }

* [Microsoft documentation](https://docs.microsoft.com/fr-fr/azure/container-registry/)

## Operations
{: .text-blue-300 }

### Connect to ACR
{: .text-blue-200 }

```bash
az acr login --name mesfContainerRegistry
```

### Push images
{: .text-blue-200 }

```powershell
docker tag geolocationapi:dev  mesfcontainerregistry.azurecr.io/huntergames/geolocationapi
docker push mesfcontainerregistry.azurecr.io/huntergames/geolocationapi
```

### List images in the repository
{: .text-blue-200 }

```bash
az acr repository list -n mesfContainerRegistry  

az acr repository show -n mesfContainerRegistry --repository ygo  

az acr repository show-tags -n mesfContainerRegistry --repository ygo  

az acr repository delete -n mesfContainerRegistry --repository jenkins-slave
```
