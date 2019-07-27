# ----------------------------------------------------
# Create Network Interface
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
    ResourceGroupName = $inventoryVars.debug_values.network_interace.resourceGroupName
    Location          = $inventoryVars.location
}
$azResourceGroup = Set-MESFAzResourceGroup @resourceParams

Import-Module MESF_Azure -Force
Enable-MESF_AzureDebug

try {
    $vnet = Set-MESFAzVirtualNetwork -ResourceGroupName $azResourceGroup.ResourceGroupName `
                                     -Location $azResourceGroup.Location `
                                     -Network $inventoryVars.debug_values.virtual_network

    $publicIpAddress = Set-MESFAzPublicIpAddress -ResourceGroupName $azResourceGroup.ResourceGroupName `
                                                 -Location $azResourceGroup.Location `
                                                 -Name $inventoryVars.debug_values.public_ip.name `
                                                 -DomainNameLabel $inventoryVars.debug_values.public_ip.alias


    $subnet = Get-MESFAzVirtualNetworkSubnetConfig -ResourceGroupName $azResourceGroup.ResourceGroupName `
                                                   -Location $azResourceGroup.Location `
                                                   -NetworkName $inventoryVars.debug_values.virtual_network.Name `
                                                   -SubnetName $inventoryVars.debug_values.virtual_network.Subnets[0].Name

    Set-MESFAzNetworkInterface -ResourceGroupName $azResourceGroup.ResourceGroupName `
                               -Location $azResourceGroup.Location `
                               -Name $inventoryVars.debug_values.network_interace.name `
                               -SubnetId $subnet.Id `
                               -PublicIpAddressId $publicIpAddress.Id


    Remove-AzResourceGroup -Id $azResourceGroup.ResourceId
}
catch {
    Write-Error $_
}


