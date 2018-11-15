
#Source : https://kevinmarquette.github.io/2017-01-21-powershell-module-continious-delivery-pipeline/?utm_source=blog&utm_medium=blog&utm_content=body&utm_content=module

$projectRoot = Resolve-Path "$PSScriptRoot\.."
$sourceRoot = [System.IO.Path]::Combine($PSScriptRoot, "MESF_Azure")
$sourceRoot = $projectRoot 
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf

Write-Verbose "Importing Functions"

# Import everything in these folders
foreach($folder in @('Models', 'Cross-Cutting','Core','Network','VirtualMachines','private\Network'))
{
    
    $root = [System.IO.Path]::Combine($sourceRoot, "MESF_Azure", $folder)
    if(Test-Path -Path $root)
    {
        Write-Verbose "processing folder $root"
        $files = Get-ChildItem -Path $root -Filter *.ps1

        # dot source each file
        $files | where-Object{ $_.name -NotLike '*.Tests.ps1'} | 
            ForEach-Object{Write-Verbose $_.name; . $_.FullName}
    }
}

#Export-ModuleMember -Function (Get-ChildItem -Path "$sourceRoot\Public\*.ps1").basename