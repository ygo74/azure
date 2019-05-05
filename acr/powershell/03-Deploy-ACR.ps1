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


foreach ($registry in $inventoryVars.registries)
{

    #Ensure ResourceGroup exists
    $resourceParams = @{
        ResourceGroupName = $registry.ResourceGroupName
        Location          = $registry.Location
        Whatif            = $whatif
    }
    $azResourceGroup = Set-ResourceGroup @resourceParams

    #Create
    $azRegistry = Set-ContainerRegistry -Registry $registry -WhatIf:$whatif

    $azRegistry
}

return

$registry = New-AzContainerRegistry -ResourceGroupName $ResourceGroupName `
                                    -Name $RegistryName `
                                    -EnableAdminUser `
                                    -Sku Basic

#Login to registry
$creds = Get-AzContainerRegistryCredential -Registry $registry
$creds.Password | docker login $registry.LoginServer -u $creds.Username --password-stdin

#Send image to registry
docker tag microsoft/windowsservercore mesfcontainerregistry.azurecr.io/windowsservercore:latest
docker tag ygo74/winrmenabled mesfcontainerregistry.azurecr.io/winrmenabled:latest

docker push mesfcontainerregistry.azurecr.io/windowsservercore:latest
docker push mesfcontainerregistry.azurecr.io/winrmenabled:latest

docker rmi mesfcontainerregistry.azurecr.io/windowsservercore:latest
docker rmi mesfcontainerregistry.azurecr.io/winrmenabled:latest

docker run mesfcontainerregistry.azurecr.io/winrmenabled:latest