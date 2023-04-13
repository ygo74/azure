Function Import-MESFAnsibleInventory
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$false, Position=0)]
        [String]
        $InventoryPath
    )
    Process
    {
        #Resolve Inventory directory
        $fullConfigurationFilePath = Resolve-Path -Path $InventoryPath

        #Load yaml files from inventory directory
        $inventoryVars = @{}
        Get-ChildItem -Path $fullConfigurationFilePath.Path -Include "*.yml","*.yaml" -Recurse | ForEach-Object {
            $vars = ConvertFrom-Yaml -Yaml ((Get-Content -Path $_.FullName) -join("`n")) -Ordered -UseMergingParser
            foreach($key in $vars.keys)
            {
                $inventoryVars[ $key ] = $vars[ $key ]
            }
        }

        Write-Output $inventoryVars

    }
}