$global:Location = "westeurope"
$global:ResourceGroupName = "AKS"
$global:Author = "YGO74"

$global:virtualNetworks=@(
    New-Object -TypeName PsObject -Property @{
            Name="ContinuousIntegration_Network"
            AddressPrefix="10.2.0.0/16"
            Subnets=@(
                New-Object -TypeName PsObject -Property @{
                    Name="Front"
                    AddressPrefix="10.2.1.0/24"
                }
            )
        }
)

# $global:VirtualMachines=@(
#     New-Object -TypeName PsObject -Property @{
#         Name="ci-lx-master"
#         ComputerName="lxjnk-master"
#         Size="Standard_DS1_v2"
#         Type="Linux"
#         Publisher="Canonical"
#         Offer="UbuntuServer"
#         skus="16.04-LTS"
#         StorageType="Premium_LRS"
#         DiskName="Vm1_Disk"
#         DiskSize=40
#         NetworkName="ContinuousIntegration_Network"
#         SubnetName="Services"
#         SshPublicKey = (Get-Content "$env:USERPROFILE\.ssh\.azureuser.pub")
#         Extensions = @{
#             "JavaJre" = $AzureRmVMExtensionsUbuntu.JavaJre
#             "Jenkins" = $AzureRmVMExtensionsUbuntu.Jenkins
#             "Ansible" = $AzureRmVMExtensionsUbuntu.Ansible
#         }    
#     }
#     New-Object -TypeName PsObject -Property @{
#         Name="ci-lx-Slave-1"
#         ComputerName="lxjnk-slave-1"
#         Size="Standard_DS1_v2"
#         Type="Linux"
#         Publisher="Canonical"
#         Offer="UbuntuServer"
#         skus="16.04-LTS"
#         StorageType="Premium_LRS"
#         DiskName="Vm1_Disk"
#         DiskSize=40
#         NetworkName="ContinuousIntegration_Network"
#         SubnetName="Back"
#         SshPublicKey = (Get-Content "$env:USERPROFILE\.ssh\.azureuser.pub")    
#         Extensions = @{
#             "JavaJre" = $AzureRmVMExtensionsUbuntu.JavaJre
#             "Ansible" = $AzureRmVMExtensionsUbuntu.Ansible
#         }    

#     }
#     New-Object -TypeName PsObject -Property @{
#         Name="ci-win-Slave-1"
#         ComputerName="winjnk-slave-1"
#         Size="Standard_DS1_v2"
#         Type="Windows"
#         Publisher="MicrosoftWindowsServer"
#         Offer="WindowsServer"
#         skus="2016-Datacenter-smalldisk"
#         StorageType="Standard_LRS"
#         DiskName="Vm1_Disk"
#         DiskSize=40
#         NetworkName="ContinuousIntegration_Network"
#         SubnetName="Back"
#         Extensions = @{
#             "Winrm" = $AzureRmVMExtensionsWindows.WinrmActivation
#         }    
#     }
#     New-Object -TypeName PsObject -Property @{
#         Name="ci-lx-admin"
#         ComputerName="lx-ci-admin"
#         Size="Standard_DS1_v2"
#         Type="Linux"
#         Publisher="Canonical"
#         Offer="UbuntuServer"
#         skus="16.04-LTS"
#         StorageType="Premium_LRS"
#         DiskName="Vm1_Disk"
#         DiskSize=40
#         NetworkName="ContinuousIntegration_Network"
#         SubnetName="Services"
#         SshPublicKey = (Get-Content "$env:USERPROFILE\.ssh\.azureuser.pub")
#         EnablePublicIp = $true
#         Extensions = @{
#             "Ansible" = $AzureRmVMExtensionsUbuntu.Ansible
#         }    
#     }

# )
