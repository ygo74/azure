if ([String]::IsNullOrEmpty($PSScriptRoot)) {
    $rootScriptPath = "D:\devel\github\devops-toolbox\cloud\azure\acr\powershell"
}
else {
    $rootScriptPath = $PSScriptRoot
}

$ModulePath = "$rootScriptPath\..\..\powershell\modules\MESF_Azure\MESF_Azure\MESF_Azure.psd1"
Import-Module $ModulePath -force

#$Credential = Get-Credential -Message "Type the name and password of the local administrator account."

#Load configuration
& "$rootScriptPath\00-Configuration.ps1"

Set-ResourceGroup -ResourceGroupName $ResourceGroupName -Location $Location

$registry = New-AzContainerRegistry -ResourceGroupName $ResourceGroupName `
                                    -Name $RegistryName `
                                    -EnableAdminUser `
                                    -Sku Basic

#Login to registry
$creds = Get-AzContainerRegistryCredential -Registry $registry
$creds.Password | docker login $registry.LoginServer -u $creds.Username --password-stdin

#Send image to registry
