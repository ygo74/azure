---
layout: default
title: User managed identities
parent: Base objects commands
nav_order: 5
has_children: false
---

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>


## Managed User Identity

### Create Identity

1. Ansible

    {: .warning-title }
    > User managed identities not yet implemented in ansible azure azure.azcollection v1.15
    >

2. Azure CLI

    Source : <https://learn.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest#az-identity-create>{:target="_blank"}

    ``` powershell
    $identityName = "umi-aks-bootsrap"
    $resourceGroup = "rg-francecentral-managed_identities"
    $tags = "scope=bootstrap"

    # Create identity
    az identity create --name $identityName --resource-group $resourceGroup --tags $tags

    ```

### Get Identity's service principal

1. Ansible

    {: .warning-title }
    > User managed identities not yet implemented in ansible azure azure.azcollection v1.15
    >

2. Azure CLI

    Sources :

    * <https://learn.microsoft.com/en-us/cli/azure/identity?view=azure-cli-latest#az-identity-create>{:target="_blank"}
    * <https://learn.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-show>{:target="_blank"}

    ``` powershell
    $identityName = "umi-aks-bootsrap"
    $resourceGroup = "rg-francecentral-managed_identities"

    # Get principal identity
    $identityPrincipalId =$(az identity show --name $identityName --resource-group $resourceGroup --query "principalId" -o tsv)
    write-host "Identity Principal Id : $identityPrincipalId"

    # Show principal definition
    az ad sp show --id $identityPrincipalId
    ```

## Service Principal

1. ***Create an application***

    ```powershell
    New-AzADApplication -DisplayName aksBootstrap
    $application = Get-AzADApplication -DisplayName aksBootstrap
    ```

2. ***Create a Service Principal***

    ```powershell
    Add-Type -Assembly System.Web
    $password = [System.Web.Security.Membership]::GeneratePassword(16,3)
    $securePassword = ConvertTo-SecureString -Force -AsPlainText -String $password
    New-AzADServicePrincipal -ApplicationId $application.AppId -Password $securePassword

    $svcPrincipal = Get-AzADServicePrincipal -DisplayName Ansible-Automation
    $svcPrincipal |fl *
