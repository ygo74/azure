if ([String]::IsNullOrEmpty($PSScriptRoot)) {
    $rootScriptPath = "D:\devel\github\devops-toolbox\cloud\azure\service fabric\powershell"
}
else {
    $rootScriptPath = $PSScriptRoot
}    

$ModulePath = "$rootScriptPath\..\..\powershell\modules\MESF_Azure\MESF_Azure\MESF_Azure.psd1" 
Import-Module $ModulePath -force


#Load Vault configuration
& "$rootScriptPath\00-Configuration.ps1"

#Ensure ResourceGroup exist for the Vault
Set-MESFAzResourceGroup -ResourceGroupName $ResourceGroupName -Location $Location


$CertSubjectName="sfcluster1.westeurope.cloudapp.azure.com"
$certPassword="Password123!@#" | ConvertTo-SecureString -AsPlainText -Force 
$vmpassword="Password4321!@#" | ConvertTo-SecureString -AsPlainText -Force
$vmuser="myadmin"
$os="WindowsServer2016DatacenterwithContainers"
$certOutputFolder="$($env:USERPROFILE)\.mesf_azure"
$parameterFilePath="D:\devel\github\Azure-Samples\service-fabric-cluster-templates\5-VM-Windows-1-NodeTypes-Secure\AzureDeploy.Parameters.json"
$templateFilePath="D:\devel\github\Azure-Samples\service-fabric-cluster-templates\5-VM-Windows-1-NodeTypes-Secure\AzureDeploy.json"
                    
                    
New-AzureRmServiceFabricCluster -Name "sfcluster1" -ResourceGroupName $resourceGroupName -Location $Location -KeyVaultResouceGroupName $vaultResourceGroupName -KeyVaultName $vaultName -CertificateOutputFolder $certOutputFolder -CertificatePassword $certpassword -CertificateSubjectName $CertSubjectName -OS $os -VmPassword $vmpassword -VmUserName $vmuser


#-TemplateFile $templateFilePath -ParameterFile $parameterFilePath

