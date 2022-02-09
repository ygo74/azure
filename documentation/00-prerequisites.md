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


## Powershell MESF modules Development configuration

1. Register the MESF Module folder in the PSModulePath

    ```Powershell
    # Get current value
    $CurrentValue = [Environment]::GetEnvironmentVariable("PSModulePath", "Machine")

    # Modify current value with your folder
    [Environment]::SetEnvironmentVariable("PSModulePath", $CurrentValue + ";D:\devel\github\devops-toolbox\cloud\azure\powershell\modules\MESF_Azure", "Machine")
    ```

> :warning:  
> __Restart your development editor or powershell session__

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

1. ***Create an application***

    ```powershell
    New-AzureRmADApplication -DisplayName Ansible-Automation -IdentifierUris http://azure/ansible
    $application = Get-AzureRmADApplication -DisplayName Ansible-Automation
    ```

2. ***Create a Service Principal***

    ```powershell
    Add-Type -Assembly System.Web
    $password = [System.Web.Security.Membership]::GeneratePassword(16,3)
    $securePassword = ConvertTo-SecureString -Force -AsPlainText -String $password
    New-AzureRmADServicePrincipal -ApplicationId $application.ApplicationId -Password $securePassword

    $svcPrincipal = Get-AzureRmADServicePrincipal -DisplayName Ansible-Automation
    $svcPrincipal |fl *
    ```

3. ***Assign Contributor permission to All the subscription***

    ```powershell
    $subscriptionId=Get-AzureRmSubscription | select-object -ExpandProperty Id
    New-AzureRmRoleAssignment  -ObjectId $svcPrincipal.Id  -RoleDefinitionName Contributor -Scope "/subscriptions/$subscriptionId"
    ```

### Create Service Principal for Jenkins to Access to ACR

Goal : Have a service principal to allow Jenkins to communicate with ACR

1. ***Create an application***

    ```powershell
    New-AzureRmADApplication -DisplayName Jenkins-ACR -IdentifierUris http://azure/jenkins-acr
    $application = Get-AzureRmADApplication -DisplayName Jenkins-ACR
    ```

2. ***Create a Service Principal***

    ```powershell
    Add-Type -Assembly System.Web
    $password = [System.Web.Security.Membership]::GeneratePassword(16,3)
    $securePassword = ConvertTo-SecureString -Force -AsPlainText -String $password
    New-AzureRmADServicePrincipal -ApplicationId $application.ApplicationId -Password $securePassword

    $svcPrincipal = Get-AzureRmADServicePrincipal -DisplayName Jenkins-ACR
    $svcPrincipal |fl *
    ```

3. ***Retrieve Azure Container Registry***

    ```powershell
    $registry = Get-AzureRmContainerRegistry -ResourceGroupName "AKS" -Name mesfContainerRegistry
    ```

4. ***Assign Contributor permission to All the subscription***

    ```powershell
    $subscriptionId=Get-AzureRmSubscription | select-object -ExpandProperty Id
    New-AzureRmRoleAssignment  -ObjectId $svcPrincipal.Id  -RoleDefinitionName Contributor -Scope $registry.Id
    ```
