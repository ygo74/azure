---
layout: default
title: Define Service principal
parent: Prerequisites
nav_order: 5
has_children: false
---

## Source

* [Using Administration Portal](https://docs.microsoft.com/fr-fr/azure/active-directory/develop/howto-create-service-principal-portal)
* [Using Azure Powershell](https://docs.microsoft.com/fr-fr/azure/active-directory/develop/howto-authenticate-service-principal-powershell)

https://docs.microsoft.com/fr-fr/powershell/azure/create-azure-service-principal-azureps?view=azps-2.2.0#sign-in-using-a-service-principal

## Service Principal View

* Portal : Navigate to Azure Active Directory / App registrations
* Powershell :

    ```powershell
    Get-AzADServicePrincipal
    ```

## Create Service Principal for Ansible Automation

1. ***Create an application***

    ```powershell
    New-AzADApplication -DisplayName Ansible-Automation -IdentifierUris http://azure/ansible
    $application = Get-AzADApplication -DisplayName Ansible-Automation
    ```

2. ***Create a Service Principal***

    ```powershell
    Add-Type -Assembly System.Web
    $password = [System.Web.Security.Membership]::GeneratePassword(16,3)
    $securePassword = ConvertTo-SecureString -Force -AsPlainText -String $password
    New-AzADServicePrincipal -ApplicationId $application.ApplicationId -Password $securePassword

    $svcPrincipal = Get-AzADServicePrincipal -DisplayName Ansible-Automation
    $svcPrincipal |fl *
    ```

3. ***Assign Contributor permission to All the subscription***

    ```powershell
    $subscriptionId=Get-AzSubscription | select-object -ExpandProperty Id
    New-AzRoleAssignment  -ObjectId $svcPrincipal.Id  -RoleDefinitionName Contributor -Scope "/subscriptions/$subscriptionId"
    ```

## Create Service Principal for Jenkins to Access to ACR

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
