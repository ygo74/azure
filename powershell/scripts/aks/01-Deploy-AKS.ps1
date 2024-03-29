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

# Ensure ResourceGroup exist for the Vault
$resourceParams = @{
    ResourceGroupName = $inventoryVars.aks.resource_group
    Location          = $inventoryVars.location
}
$azResourceGroup = Set-MESFAzResourceGroup @resourceParams

# Create AKS Virtual Network
Set-MESFAzVirtualNetwork -ResourceGroupName $azResourceGroup.ResourceGroupName `
                         -Location $azResourceGroup.Location `
                         -Network $inventoryVars.aks.virtual_network



# Retrieve AKS CLuster
$existingCluster = Get-AzResource -ResourceGroupName $azResourceGroup.ResourceGroupName `
                                  -Name $inventoryVars.aks.cluster_name `
                                  -ErrorAction SilentlyContinue


# Create AKS CLuster
# az login
# az aks get-versions --location $Location
if($null -eq $existingCluster)
{
    # v1.13.10 : rbac is enabled by default. if no rbac option is --disable-rbac
    az aks create --resource-group $azResourceGroup.ResourceGroupName `
                  --name $inventoryVars.aks.cluster_name `
                  --node-count 1 `
                  --node-vm-size $inventoryVars.aks.node_vm_size `
                  --ssh-key-value (Get-Content "$env:USERPROFILE\.ssh\.azureuser.pub") `
                  --enable-addons http_application_routing

    # Set rights for dashboard
    kubectl create clusterrolebinding kubernetes-dashboard -n kube-system --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

}