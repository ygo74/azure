# Azure Container Registry : ACR
Goal : Docker image repository

Microsoft documentation : https://docs.microsoft.com/fr-fr/azure/container-registry/

## Deployment
### Deploy with Ansible
TODO

### Deploy with Powershell

## Operations
### Connect to ACR
az acr login --name mesfContainerRegistry

### Push images
```powershell
docker tag geolocationapi:dev  mesfcontainerregistry.azurecr.io/huntergames/geolocationapi
docker push mesfcontainerregistry.azurecr.io/huntergames/geolocationapi
```


### List images in the repository
az acr repository list -n mesfContainerRegistry  

az acr repository show -n mesfContainerRegistry --repository ygo  

az acr repository show-tags -n mesfContainerRegistry --repository ygo  

az acr repository delete -n mesfContainerRegistry --repository jenkins-slave