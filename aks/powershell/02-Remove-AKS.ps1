[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory = $false, Position = 0)]
    [ValidateScript({Test-Path -Path $_ -PathType Container})]
    [string]
    $InventoryPath = "..\..\ansible\group_vars"
)

# Load Module
Import-Module MESF_Azure

# Load yaml files from inventory directory
$inventoryVars = Import-MESFAnsibleInventory -InventoryPath $InventoryPath

$whatif = $PSBoundParameters.ContainsKey('WhatIf')

$whatif

# Remove Resource Group
Remove-AzResourceGroup -Name $inventoryVars.aks.resource_group -Force
