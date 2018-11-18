if ([String]::IsNullOrEmpty($PSScriptRoot)) {
    $rootScriptPath = "D:\devel\Azure\git\microsvc\azure\scripts\04-Ansible-lab"
}
else {
    $rootScriptPath = $PSScriptRoot
}    

$ModulePath = "$rootScriptPath\..\..\powershell\MESF_Azure\MESF_Azure\MESF_Azure.psd1" 
Import-Module $ModulePath -force


#Load Ansible lab configuration
& "$rootScriptPath\00-Configuration.ps1"

Set-ResourceGroup -ResourceGroupName $ResourceGroupName -Location $Location

foreach($virtualNetwork in $virtualNetworks)
{
    Set-VirtualNetwork -ResourceGroupName $ResourceGroupName -Location $Location -Network $virtualNetwork
}

# foreach($PublicIpKey in $PublicIps.Keys)
# {
#     $publicIp = $PublicIps[$PublicIpKey]
#     Set-PublicIP -ResourceGroupName $ResourceGroupName -Location $location `
#                  -Name $publicIp.Name -Alias $publicIp.Alias
# }

foreach($virtualMachine in $virtualMachines)
{
        Set-VirtualMachine -ResourceGroupName $ResourceGroupName -Location $Location -VirtualMachine $virtualMachine
}    

#Remove-AzureRmResourceGroup -Name $ResourceGroupName

# Install NGINX.
# $PublicSettings = '{"commandToExecute":"apt-get -y update && apt-get -y install nginx"}'

# Set-AzureRmVMExtension -ExtensionName "NGINX" -ResourceGroupName $ResourceGroupName -VMName "Vm2" `
#   -Publisher "Microsoft.Azure.Extensions" -ExtensionType "CustomScript" -TypeHandlerVersion 2.0 `
#   -SettingString $PublicSettings -Location $location


#pip install
#sudo apt-get install python-pip
#sudo pip install "pywinrm>=0.3.0"
# error
# => https://askubuntu.com/questions/955546/pip-attributeerror-module-object-has-no-attribute-ssl-st-init
# sudo rm -rf /usr/lib/python2.7/dist-packages/OpenSSL/
# sudo pip install pyOpenSSL

$Vm2Extensions = @(
        $AzureRmVMExtensionsLinux.PythonPackager, 
        $AzureRmVMExtensionsLinux.Ansible, 
        $AzureRmVMExtensionsLinux.AnsibleWindowsRequirement)
$PublicSettings = '{"commandToExecute": "' + ($Vm2Extensions -join ';') + '"}'
Set-AzureRmVMExtension -ExtensionName "Ansible" -ResourceGroupName $ResourceGroupName -VMName "AnsibleController" `
  -Publisher "Microsoft.Azure.Extensions" -ExtensionType "CustomScript" -TypeHandlerVersion 2.0 `
  -SettingString $PublicSettings -Location $location


$Vm1Extensions = @($AzureRmVMExtensionsWindows.WinrmActivation)
$PublicSettings = '{"commandToExecute": "' + ($Vm1Extensions -join ';') + '"}'
Set-AzureRmVMExtension -ExtensionName "WinRmActivation" -ResourceGroupName $ResourceGroupName -VMName "MssqlDefault" `
-Publisher "Microsoft.Compute" -ExtensionType "CustomScriptExtension" -TypeHandlerVersion 1.9 `
-SettingString $PublicSettings -Location $location
  

#winrm basic
# winrm set winrm/config/client/auth @{Basic="true"} 
# winrm set winrm/config/service/auth @{Basic="true"} 
# winrm set winrm/config/service @{AllowUnencrypted="true"}
