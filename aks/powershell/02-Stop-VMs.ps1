if ([String]::IsNullOrEmpty($PSScriptRoot)) {
    $rootScriptPath = "D:\devel\github\devops-toolbox\cloud\azure\aks\powershell"
}
else {
    $rootScriptPath = $PSScriptRoot
}    

$ModulePath = "$rootScriptPath\..\..\powershell\modules\MESF_Azure\MESF_Azure\MESF_Azure.psd1" 
Import-Module $ModulePath -force


& "$rootScriptPath\00-Configuration.ps1"

$jobs = Get-AzureRmVM -ResourceGroupName $ResourceGroupName | Stop-AzureRmVM -AsJob

#$jobs = get-job
$jobs | Wait-Job
$jobs | Receive-Job

