# Module MESF Azure features

This module brings the idempotent features on top of the Microsoft Azure powershell modules. It also has specific features that you can use or not but help me to my research :  
* Local vault management
* Ansible inventory sharing

## Idempotent feature on top of the Microsoft Azure powershell modules

## Local vault management
1. Register-MESFAzureServicePrincipal  
   Create application and service principal based on the application name.  
   The password is automatically generated and saved in the local vault.  
   You can also reset the password with the switch ResetPassword

2. Get-MESFClearPAssword  
   Decrypt password from a SecureString password

3. Remove-MESFAzureServicePrincipal  
   Remove application and service principal based on the application name.  
   Remove also the service principal from the local vault

4. Sync-MESFAzureVault  
   Synchronize Azure vault with local vault.  
   > :warning:  
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