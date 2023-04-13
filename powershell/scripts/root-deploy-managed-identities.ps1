[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory = $false, Position = 0)]
    [ValidateScript({Test-Path -Path $_ -PathType Container})]
    [string]
    $InventoryPath = "inventory/root/group_vars/all"
)

Begin
{
    $ErrorActionPreference = "Stop"
    $whatif = $PSBoundParameters.ContainsKey('WhatIf')
}

Process
{
    # Load Module
    # Import-Module MESF_Azure

    $InventoryFullPath = Resolve-Path -Path $InventoryPath | Select-Object -ExpandProperty Path

    # Load yaml files from inventory directory
    $inventoryVars = Import-MESFAnsibleInventory -InventoryPath $InventoryFullPath
    $inventoryVars

    # Browse Managed Identities


}


