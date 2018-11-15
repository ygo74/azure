if ([String]::IsNullOrEmpty($PSScriptRoot)) {
    $rootScriptPath = "D:\devel\Azure\git\microsvc\azure\scripts\01-ContinuousIntegration"
}
else {
    $rootScriptPath = $PSScriptRoot
}    

$ModulePath = "$rootScriptPath\..\..\powershell\MESF_Azure\MESF_Azure\MESF_Azure.psd1" 
Import-Module $ModulePath -force


& "$rootScriptPath\00-Configuration.ps1"

Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force
