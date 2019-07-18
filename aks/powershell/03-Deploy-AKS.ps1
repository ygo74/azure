if ([String]::IsNullOrEmpty($PSScriptRoot)) {
    $rootScriptPath = "D:\devel\github\devops-toolbox\cloud\azure\aks\powershell"
}
else {
    $rootScriptPath = $PSScriptRoot
}    

$ModulePath = "$rootScriptPath\..\..\powershell\modules\MESF_Azure\MESF_Azure\MESF_Azure.psd1" 
Import-Module $ModulePath -force

$Credential = Get-Credential -Message "Type the name and password of the local administrator account."

#Load AKS configuration
& "$rootScriptPath\00-Configuration.ps1"

Set-MESFAzResourceGroup -ResourceGroupName $ResourceGroupName -Location $Location

#Create Network Infrastrtcuture
foreach($virtualNetwork in $virtualNetworks)
{
    Set-VirtualNetwork -ResourceGroupName $ResourceGroupName -Location $Location -Network $virtualNetwork
}



#Create AKS CLuster
$aksClusterName = "myAKSCluster"
az login
az aks get-versions --location $Location

$existingCluster = Get-AzureRmResource -ResourceGroupName $ResourceGroupName -Name $aksClusterName -ErrorAction SilentlyContinue
if($null -eq $existingCluster)
{
    az aks create --resource-group $ResourceGroupName `
                  --name $aksClusterName `
                  --node-count 1 `
                  --ssh-key-value (Get-Content "$env:USERPROFILE\.ssh\.azureuser.pub")
                  
}    