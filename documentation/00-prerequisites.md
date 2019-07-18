# Prerequisites for Azure Automation

* [Powershell Az modules Installation and configuration](#Powershell-Az-modules-Installation-and-configuration)
* [Ansible installation and configuration](#Ansible-installation-and-configuration)
* [Powershell MESF modules Development configuration](#Powershell-MESF-modules-Development-configuration)

## Powershell Az modules Installation and configuration

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

## Ansible installation and configuration

### Installation
Standard Installation : Got to automation/ansible/README.md
Azure prerequisites : TODO

### Configuration
__VSCode__ : "C:\Users\Administrator\.vscode\ansible-credentials.yml"


## Powershell MESF modules Development configuration


## Declare Variables
* a Resource Group : AKS
* a Container Registry : mesfContainerRegistry
* a AKS cluster : aksCluster

## Create A Service Principal
### Source
* [Using Administration Portal](https://docs.microsoft.com/fr-fr/azure/active-directory/develop/howto-create-service-principal-portal)
* [Using Azure Powershell](https://docs.microsoft.com/fr-fr/azure/active-directory/develop/howto-authenticate-service-principal-powershell)

https://docs.microsoft.com/fr-fr/powershell/azure/create-azure-service-principal-azureps?view=azps-2.2.0#sign-in-using-a-service-principal

### Service Principal View
* Portal : Navigate to Azure Active Directory / App registrations
* Powershell :
```powershell
Get-AzureRmADServicePrincipal
```

### Create Service Principal for Ansible Automation
***Create an application***
```powershell
New-AzureRmADApplication -DisplayName Ansible-Automation -IdentifierUris http://azure/ansible
$application = Get-AzureRmADApplication -DisplayName Ansible-Automation
```

***Create a Service Principal***
```powershell
Add-Type -Assembly System.Web
$password = [System.Web.Security.Membership]::GeneratePassword(16,3)
$securePassword = ConvertTo-SecureString -Force -AsPlainText -String $password
New-AzureRmADServicePrincipal -ApplicationId $application.ApplicationId -Password $securePassword

$svcPrincipal = Get-AzureRmADServicePrincipal -DisplayName Ansible-Automation
$svcPrincipal |fl *
```

***Assign Contributor permission to All the subscription***
```
$subscriptionId=Get-AzureRmSubscription | select-object -ExpandProperty Id
New-AzureRmRoleAssignment  -ObjectId $svcPrincipal.Id  -RoleDefinitionName Contributor -Scope "/subscriptions/$subscriptionId"
```

### Create Service Principal for Jenkins to Access to ACR
Goal : Have a service principal to allow Jenkins to communicate with ACR
***Create an application***
```powershell
New-AzureRmADApplication -DisplayName Jenkins-ACR -IdentifierUris http://azure/jenkins-acr
$application = Get-AzureRmADApplication -DisplayName Jenkins-ACR
```

***Create a Service Principal***
```powershell
Add-Type -Assembly System.Web
$password = [System.Web.Security.Membership]::GeneratePassword(16,3)
$securePassword = ConvertTo-SecureString -Force -AsPlainText -String $password
New-AzureRmADServicePrincipal -ApplicationId $application.ApplicationId -Password $securePassword

$svcPrincipal = Get-AzureRmADServicePrincipal -DisplayName Jenkins-ACR
$svcPrincipal |fl *
```

***Retrieve Azure Container Registry***
```powershell
$registry = Get-AzureRmContainerRegistry -ResourceGroupName "AKS" -Name mesfContainerRegistry
```

***Assign Contributor permission to All the subscription***
```
$subscriptionId=Get-AzureRmSubscription | select-object -ExpandProperty Id
New-AzureRmRoleAssignment  -ObjectId $svcPrincipal.Id  -RoleDefinitionName Contributor -Scope $registry.Id
```
