# Module MESF Azure features

This module brings the idempotent features on top of the Microsoft Azure powershell modules. It also has specific features that you can use or not but help me to my research :  
* Local vault management
* Ansible inventory sharing

## Idempotent feature on top of the Microsoft Azure powershell modules

## Local vault management

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