[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory = $false, Position = 0)]
    [ValidateScript({Test-Path -Path $_ -PathType Container})]
    [string]
    $InventoryPath = "..\..\ansible\group_vars"
)

#Resolve Inventory directory
$fullConfigurationFilePath = Resolve-Path -Path $InventoryPath

#Load yaml files from inventory directory
$inventoryVars = @{}
Get-ChildItem -Path $fullConfigurationFilePath.Path -Include "*.yml","*.yaml" -Recurse | ForEach-Object {
    $vars = ConvertFrom-Yaml -Yaml ((Get-Content -Path $_.FullName) -join("`n"))
    $inventoryVars += $vars
}

if ([String]::IsNullOrEmpty($PSScriptRoot)) {
    $rootScriptPath = "D:\devel\github\devops-toolbox\cloud\azure\acr\powershell"
}
else {
    $rootScriptPath = $PSScriptRoot
}

$ModulePath = "$rootScriptPath\..\..\powershell\modules\MESF_Azure\MESF_Azure\MESF_Azure.psd1"
Import-Module $ModulePath -force

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


