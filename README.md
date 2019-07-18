# Devops Toolbox - Azure

Test and deploy many features on Azure Cloud. Features can be built-in features (such ACR, AKS, ...) or custom features (such as Jenkins CI platforms,...).

The goal is to learn, test and compare some tools to do the same stuff (powershell, jenkins, ...) and at the end to compare some cloud providers

As we don't like to write the same code / configuration in different files, the azure devops toolbox is supported by :
* Shared configuration files
* A powershell module which uses these configuration files and acts as a wrapper for idempotence operations on Standard Azure command

## Azure features
## Built-in Azure features deployment and Operations

| Azure feature | Description |
|---------------|-------------|
| [Azure Container Registry](acr/README.md) | Azure Container Registry allows you to build, store, and manage images for all types of container deployments |
| [Azure Kubernetes Service](aks/readme.md) | |
| [Service Fabric](service fabric/README.md) | |
| [Vault](vault/README.md) | |

## Custom Deployment
| Deployment Model | Description |
|------------------|-------------|
| [jenkins](jenkins) | |



