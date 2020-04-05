# ----------------------------------------------------
# Create Public IP
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
    ResourceGroupName = $inventoryVars.debug_values.public_ip.resourceGroupName
    Location          = $inventoryVars.location
}
$azResourceGroup = Set-MESFAzResourceGroup @resourceParams

Import-Module MESF_Azure -Force
Enable-MESF_AzureDebug

try {
    Set-MESFAzVirtualNetwork -ResourceGroupName $azResourceGroup.ResourceGroupName `
                             -Location $azResourceGroup.Location `
                             -Network $inventoryVars.debug_values.virtual_network

    Set-MESFAzPublicIpAddress -ResourceGroupName $azResourceGroup.ResourceGroupName `
                              -Location $azResourceGroup.Location `
                              -Name $inventoryVars.debug_values.public_ip.name `
                              -DomainNameLabel $inventoryVars.debug_values.public_ip.alias

    Remove-AzResourceGroup -Id $azResourceGroup.ResourceId
}
catch {
    Write-Error $_
}


