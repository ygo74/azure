[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory = $false, Position = 0)]
    [ValidateScript({Test-Path -Path $_ -PathType Container})]
    [string]
    $InventoryPath = "..\..\ansible\group_vars"
)

#Load Module
Import-Module MESF_Azure

#Load yaml files from inventory directory
$inventoryVars = Import-MESFAnsibleInventory -InventoryPath $InventoryPath

$whatif = $PSBoundParameters.ContainsKey('WhatIf')

#Ensure ResourceGroup exist for the Vault
$resourceParams = @{
    ResourceGroupName = $inventoryVars.vault.resourceGroupName
    Location          = $inventoryVars.location
    Whatif            = $whatif
}
$azResourceGroup = Set-MESFAzResourceGroup @resourceParams

$currentVault = Get-AzKeyVault -VaultName $inventoryVars.vault.name `
                               -ResourceGroupName $azResourceGroup.ResourceGroupName

if ($null -eq $currentVault)
{
    #Create the Vault and enable it for deployment
    New-AzKeyVault -Name $inventoryVars.vault.name `
                -ResourceGroupName $azResourceGroup.ResourceGroupName `
                -Location $azResourceGroup.Location `
                -EnabledForDeployment

    $currentVault = Get-AzKeyVault -VaultName $inventoryVars.vault.name `
                                   -ResourceGroupName $azResourceGroup.ResourceGroupName

}

$currentVault


