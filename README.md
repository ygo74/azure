# Devops Toolbox - Azure

## Deploy Container registry : ACR

## Deploy Kubernetes Service : AKS

## Deploy Jenkins

## Ansible installation and configuration

### Installation
Standard Installation : Got to automation/ansible/README.md
Azure prerequisites : TODO

### Configuration
__VSCode__ : "C:\Users\Administrator\.vscode\ansible-credentials.yml"

## Powershell Installation and configuration

### Installation
New powershell module to use az : https://docs.microsoft.com/fr-fr/powershell/azure/install-az-ps?view=azps-1.8.0

```powershell
#Install the new module
Install-Module -Name Az -AllowClobber
Get-InstalledModule -Name Az -AllVersions | select Name,Version
Get-InstalledModule | ? {$_.Name -like 'Az*'} | select Name,Version
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
