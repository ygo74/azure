# ----------------------------------------------------
# Create Virtual Network
# ----------------------------------------------------
Import-Module MESF_Azure -Force
Enable-MESF_AzureDebug

# Load Inventory vars
$inventoryPath = (Get-Module MESF_Azure).ModuleBase
$inventoryPath = [System.IO.Path]::Combine($inventoryPath, "../../../../ansible/group_vars")
$inventoryPath = (Resolve-Path -Path $inventoryPath).Path
$inventoryVars = Import-MESFAnsibleInventory -InventoryPath $inventoryPath

#Ensure ResourceGroup exists for the Virtual Network
$resourceParams = @{
    ResourceGroupName = $inventoryVars.debug_values.virtual_network.resourceGroupName
    Location          = $inventoryVars.location
}
$azResourceGroup = Set-MESFAzResourceGroup @resourceParams

Import-Module MESF_Azure -Force
Enable-MESF_AzureDebug

try {
    Set-MESFAzVirtualNetwork -ResourceGroupName $azResourceGroup.ResourceGroupName `
                             -Location $azResourceGroup.Location `
                             -Network $inventoryVars.debug_values.virtual_network

    Remove-AzResourceGroup -Id $azResourceGroup.ResourceId
}
catch {
    Write-Error $_
}


