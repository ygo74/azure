if ([String]::IsNullOrEmpty($PSScriptRoot)) {
    $rootScriptPath = "D:\devel\github\devops-toolbox\cloud\azure\jenkins\powershell"
}
else {
    $rootScriptPath = $PSScriptRoot
}

$ModulePath = "$rootScriptPath\..\..\powershell\modules\MESF_Azure\MESF_Azure\MESF_Azure.psd1"
Import-Module $ModulePath -force

#Load Ansible lab configuration
& "$rootScriptPath\00-Configuration.ps1"

$Credential = Get-Credential -Message "Type the name and password of the local administrator account."

Set-MESFAzResourceGroup -ResourceGroupName $ResourceGroupName -Location $Location

#Create Network Infrastrtcuture
foreach($virtualNetwork in $virtualNetworks)
{
    Set-MESFAzResourceGroup -ResourceGroupName $ResourceGroupName -Location $Location -Network $virtualNetwork
}


#Create Virtual Machines
foreach($virtualMachine in $virtualMachines)
{
        Set-MESFAzVM -ResourceGroupName $ResourceGroupName -Location $Location `
                           -VirtualMachine $virtualMachine -Credential $Credential

        Set-MESFAzVMExtension -ResourceGroupName $ResourceGroupName -Location $location `
                                    -VirtualMachine $virtualMachine
}

#Create Application Gateway
Import-Module $ModulePath -force

$gatewaySettings = @{
    ResourceGroupName          = $ResourceGroupName
    Location                   = $location
    Name                       = "Gateway-CI"
    VirtualNetworkName         = $virtualNetworks[0].Name
    SubnetName                 = $virtualNetworks[0].Subnets[0].Name
    ApplicationName            = "Jenkins"
    Alias                      = "jenkins-ci-01"
    ListenerProtocol           = "Http"
    ListenerPort               = 80
    BackendProtocol            = "Http"
    BackendPort                = 8080
    BackendVirtualMachineNames = @("ci-lx-master")
}
Set-ApplicationGateway @gatewaySettings

$gatewaySettings = @{
    ResourceGroupName          = $ResourceGroupName
    Location                   = $location
    Name                       = "Gateway-CI"
    VirtualNetworkName         = $virtualNetworks[0].Name
    SubnetName                 = $virtualNetworks[0].Subnets[0].Name
    ApplicationName            = "Jenkins"
    Alias                      = "jenkins-ci-01"
    ListenerProtocol           = "Https"
    ListenerPort               = 443
    BackendProtocol            = "Http"
    BackendPort                = 8080
    BackendVirtualMachineNames = @("ci-lx-master")
    ListenerCertificateFilepath = ""
    ListenerCertificatePassword = ""
}
Set-ApplicationGateway @gatewaySettings


# #Create Load Balancers
# Set-LoadBalancer -ResourceGroupName $ResourceGroupName -Location $Location `
#                  -Name "jenkins-ci" `
#                  -Alias "jenkins-ci-01" `
#                  -VirtualMachineNames "ci-lx-master"


$rules = Get-NetworkRuleDefinition -property $Global:FirewallDefaultRules.allowSsh

#Start Security Group
$securityGroup = New-AzureRmNetworkSecurityGroup -Name "test" `
                -ResourceGroupName $ResourceGroupName -Location $Location `
                -SecurityRules $rules

Set-NetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $location `
                         -Name "NetworkSecurity" `
                         -Rules $rules


$securitGroup = Get-AzureRmNetworkSecurityGroup -Name "ContinuousIntegration-Security" `
                        -ResourceGroupName $ResourceGroupName


$vnet = Get-AzureRmVirtualNetwork   -Name $virtualNetworks.Name `
                        -ResourceGroupName $resourceGroupName `
                        -ErrorAction SilentlyContinue

$vnetConfig = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $vnet.Subnets[0].Name
$vnetConfig.NetworkSecurityGroup = $securitGroup

Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
#End Security Group

#Start Application Security Group

$webASG  =  new-AzureRmApplicationSecurityGroup  -ResourceGroupName $ResourceGroupName -Name "Test" -Location $Location

$rules = Get-NetworkRuleDefinition -property $Global:FirewallDefaultRules.allowWinrms

$azureRules = $rules | ConvertTo-AzureRMSecurityRule

$azureRules.DestinationApplicationSecurityGroups = $webASG

$securitGroup = Get-AzureRmNetworkSecurityGroup -Name "ContinuousIntegration-Security" `
                        -ResourceGroupName $ResourceGroupName

$securitGroup.SecurityRules += $azureRules

Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $securitGroup

#End Application Security group

