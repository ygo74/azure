---
layout: default
title: ACR
nav_order: 4
has_children: true
---

Goal : Docker image repository

## Sources

* [Microsoft documentation](https://docs.microsoft.com/fr-fr/azure/container-registry/)

## Operations

### Connect to ACR

```bash
az acr login --name mesfContainerRegistry
```

### Push images

```powershell
docker tag geolocationapi:dev  mesfcontainerregistry.azurecr.io/huntergames/geolocationapi
docker push mesfcontainerregistry.azurecr.io/huntergames/geolocationapi
```

### List images in the repository

```bash
az acr repository list -n mesfContainerRegistry  

az acr repository show -n mesfContainerRegistry --repository ygo  

az acr repository show-tags -n mesfContainerRegistry --repository ygo  

az acr repository delete -n mesfContainerRegistry --repository jenkins-slave
```
