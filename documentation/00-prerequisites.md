#Prerequisites for Azure Automation

## Create A Service Principal
### Source
* [Using Administration Portal](https://docs.microsoft.com/fr-fr/azure/active-directory/develop/howto-create-service-principal-portal)  
* [Using Azure Powershell](https://docs.microsoft.com/fr-fr/azure/active-directory/develop/howto-authenticate-service-principal-powershell)

### Service Principal View
* Portal : Navigate to Azure Active Directory / App registrations  
* Powershell : `Get-AzureRmADServicePrincipal`  

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
