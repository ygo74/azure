#Prerequisites for Azure Automation

## Declare Variables 
* a Resource Group : AKS
* a Container Registry : mesfContainerRegistry
* a AKS cluster : aksCluster

## Create A Service Principal
### Source
* [Using Administration Portal](https://docs.microsoft.com/fr-fr/azure/active-directory/develop/howto-create-service-principal-portal)  
* [Using Azure Powershell](https://docs.microsoft.com/fr-fr/azure/active-directory/develop/howto-authenticate-service-principal-powershell)

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
