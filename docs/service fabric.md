# Service Fabric sur Azure

https://docs.microsoft.com/fr-fr/azure/service-fabric/service-fabric-cluster-creation-via-arm




## Prerequisites
### Service Fabric Cluster Templates
Source : [Service Fabric cluster templates](https://github.com/Azure-Samples/service-fabric-cluster-templates)  

Retrieve Git
```powershell
git clone https://github.com/Azure-Samples/service-fabric-cluster-templates.git D:\devel\github\Azure-Samples\service-fabric-cluster-templates
```

### Existing KeyVault
TODO Write information

## Create Cluster


```powershell

$resourceGroupLocation="westeurope"
$resourceGroupName="sfCluster1"
$vaultName="mesfVault"
$vaultResourceGroupName="CommonVault"
$CertSubjectName="sfCluster1.westeurope.cloudapp.azure.com"
$certPassword="Password123!@#" | ConvertTo-SecureString -AsPlainText -Force 
$vmpassword="Password4321!@#" | ConvertTo-SecureString -AsPlainText -Force
$vmuser="myadmin"
$os="WindowsServer2016DatacenterwithContainers"
$certOutputFolder="$($env:USERPROFILE)\.mesf_azure"
$parameterFilePath="D:\devel\github\Azure-Samples\service-fabric-cluster-templates\5-VM-Windows-1-NodeTypes-Secure\AzureDeploy.Parameters.json"
$templateFilePath="D:\devel\github\Azure-Samples\service-fabric-cluster-templates\5-VM-Windows-1-NodeTypes-Secure\AzureDeploy.json"


New-AzureRmServiceFabricCluster -ResourceGroupName $resourceGroupName -Location $resourceGroupLocation -KeyVaultResourceGroupName $vaultResourceGroupName -KeyVaultName $vaultName -CertificateOutputFolder $certOutputFolder -CertificatePassword $certpassword -CertificateSubjectName $CertSubjectName -OS $os -VmPassword $vmpassword -VmUserName $vmuser -TemplateFile $templateFilePath -ParameterFile $parameterFilePath

``` 

## Known Exceptions

### Bad argument Name for KeyVaultResourceGroupName
Context : AzureRM.ServiceFabric v  
Typo is **KeyVaultResouceGroupName**  

### ClusterName in Lowercase
Cluster Name (Or Resource Group if cluster Name is not set) must be in lower case.  
If Cluster Name is not set, the resource group Name is used to create the cluster Name.  

