# Devops Toolbox - Azure

Test and deploy many features on Azure Cloud. Features can be built-in features (such ACR, AKS, ...) or custom features (such as Jenkins CI platforms,...).

The goal is to learn, test and compare some tools to do the same stuff (powershell, jenkins, ...) and at the end to compare some cloud providers

As we don't like to write the same code / configuration in different files, the azure devops toolbox is supported by :
=> Shared configuration files
=> A powershell module which uses these configuration files and acts as a wrapper for idempotence operations on Standard Azure command

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



## Ansible installation and configuration

### Installation
Standard Installation : Got to automation/ansible/README.md
Azure prerequisites : TODO

### Configuration
__VSCode__ : "C:\Users\Administrator\.vscode\ansible-credentials.yml"

## Powershell Installation and configuration

### Installation

| Module          | Description                           | Source                    |
|-----------------|---------------------------------------|---------------------------|
| Az              | New powershell module to manage azure | https://docs.microsoft.com/fr-fr/powershell/azure/install-az-ps?view=azps-1.8.0 |
| powershell-yaml | Serialize / Deserialize Yaml. Use to share ansible vars and powershell configuration | https://www.powershellgallery.com/packages/powershell-yaml |



```powershell
#Install the new module
Install-Module -Name Az -AllowClobber
Get-InstalledModule -Name Az -AllVersions | select Name,Version
Get-InstalledModule | ? {$_.Name -like 'Az*'} | select Name,Version

Install-Module -Name powershell-yaml
```

__Remove AzureRm modules :__
Ensure that all powershell windows (vscode included) are closed before
```powershell
#Uninstall the old azureRM powershell
Uninstall-AzureRm
```
### Configuration

__Interactive login :__ For all new powershell sessions
```powershell
# Connect to Azure with a browser sign in token
Connect-AzAccount
Get-AzSubscription
```

__Persistent login :__
Source : https://docs.microsoft.com/fr-fr/powershell/azure/context-persistence?view=azps-1.8.0

Informations are stored in __$env:USERPROFILE\.Azure__ or __$HOME/.Azure__
```powershell
# Enable context persistence
Enable-AzContextAutosave
# Connect to Azure with a browser sign in token
Connect-AzAccount

# To Disable
# Disable-AzContextAutosave
```
