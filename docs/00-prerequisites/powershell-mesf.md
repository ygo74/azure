---
layout: default
title: Install Powershell MESF
parent: Prerequisites
nav_order: 4
has_children: false
---

This module brings the idempotent features on top of the Microsoft Azure powershell modules. It also has specific features that you can use or not but help me to my research :  

* Local vault management
* Ansible inventory sharing

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

## Dependencies

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

## Local vault management

1. Register-MESFAzureServicePrincipal  

   Create application and service principal based on the application name.  
   The password is automatically generated and saved in the local vault.  
   You can also reset the password with the switch ResetPassword.  

   ```Powershell
   # ----------------------------------------------------
   # Register MESF Credential
   # ----------------------------------------------------
   Import-Module MESF_Azure -Force
   Enable-MESF_AzureDebug
   Register-MESFAzureServicePrincipal -Application TestPassword
   Register-MESFAzureServicePrincipal -Application TestPassword -ResetPassword
   ```

2. Get-MESFClearPAssword  

   Decrypt password from a SecureString password

3. Remove-MESFAzureServicePrincipal  

   Remove application and service principal based on the application name.  
   Remove also the service principal from the local vault

4. Sync-MESFAzureVault  

   Synchronize Azure vault with local vault.  
   > :warning: Limitations  
   > It doesn't remove user.

## Ansible inventory sharing

```Powershell
# Load Inventory vars
$inventoryPath = (Get-Module MESF_Azure).ModuleBase
$inventoryPath = [System.IO.Path]::Combine($inventoryPath, "../../../../ansible/group_vars")
$inventoryPath = (Resolve-Path -Path $inventoryPath).Path
$inventoryVars = Import-MESFAnsibleInventory -InventoryPath $inventoryPath
```

You get a Hashtable loaded from yam files found in ansible/group_vars. Yam files are parsed by the module powershell-yaml.  

> :warning: __Limitations__  
> Variables in Yam files can't be resolved if you use jinja2 or dynamic variables. There is no plan to adapt the behavior of Ansible.