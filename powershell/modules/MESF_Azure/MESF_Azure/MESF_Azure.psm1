
#Source : https://kevinmarquette.github.io/2017-01-21-powershell-module-continious-delivery-pipeline/?utm_source=blog&utm_medium=blog&utm_content=body&utm_content=module

$projectRoot = Resolve-Path "$PSScriptRoot\.."
$sourceRoot = [System.IO.Path]::Combine($PSScriptRoot, "MESF_Azure")
$sourceRoot = $projectRoot
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf

Write-Verbose "Importing Functions"

# Import everything in these folders
foreach($folder in @('Models', 'Cross-Cutting','Core','Network','paas','VirtualMachines','private\core','private\Network'))
{

    $root = [System.IO.Path]::Combine($sourceRoot, "MESF_Azure", $folder)
    if(Test-Path -Path $root)
    {
        Write-Verbose "processing folder $root"
        $files = Get-ChildItem -Path $root -Filter *.ps1

        # dot source each file
        $files  | where-Object{ $_.name -NotLike '*.Tests.ps1'} `
                | where-Object{ ($_.name -eq '01-Logger.ps1') -or `
                                ($_.name -eq '01-context.ps1') -or `
                                ($_.name -eq '02-Security.ps1') -or `
                                ($_.name -eq '03-AnsibleInventory.ps1') -or `
                                ($_.name -eq '03-tools.ps1') -or `
                                ($_.name -eq '01-containers.ps1') -or `
                                ($_.name -eq '02-AzureResource.ps1') } `
                | ForEach-Object{Write-Verbose $_.name; . $_.FullName}
    }
}

#Export-ModuleMember -Function (Get-ChildItem -Path "$sourceRoot\Public\*.ps1").basename