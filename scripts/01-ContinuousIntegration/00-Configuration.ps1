$global:Location = "westeurope"
$global:ResourceGroupName = "ContinuousIntegration"
$global:Author = "YGO74"

$global:virtualNetworks=@(
    New-Object -TypeName PsObject -Property @{
            Name="ContinuousIntegration_Network"
            AddressPrefix="10.0.0.0/16"
            Subnets=@(
                New-Object -TypeName PsObject -Property @{
                    Name="Front"
                    AddressPrefix="10.0.1.0/24"
                }
                New-Object -TypeName PsObject -Property @{
                    Name="Services"
                    AddressPrefix="10.0.2.0/24"
                }
                New-Object -TypeName PsObject -Property @{
                    Name="Back"
                    AddressPrefix="10.0.3.0/24"
                }
                New-Object -TypeName PsObject -Property @{
                    Name="Admin"
                    AddressPrefix="10.0.4.0/24"
                }
            )
        }
)

$global:VirtualMachines=@(
    New-Object -TypeName PsObject -Property @{
        Name="ci-lx-master"
        ComputerName="lxjnk-master"
        Size="Standard_DS1_v2"
        Type="Linux"
        Publisher="Canonical"
        Offer="UbuntuServer"
        skus="16.04-LTS"
        StorageType="Premium_LRS"
        DiskName="Vm1_Disk"
        DiskSize=40
        NetworkName="ContinuousIntegration_Network"
        SubnetName="Services"
        SshPublicKey = (Get-Content "$env:USERPROFILE\.ssh\.azureuser.pub")
        Extensions = @{
            "JavaJre" = $AzureRmVMExtensionsUbuntu.JavaJre
            "Jenkins" = $AzureRmVMExtensionsUbuntu.Jenkins
            "Ansible" = $AzureRmVMExtensionsUbuntu.Ansible
        }    
    }
    New-Object -TypeName PsObject -Property @{
        Name="ci-lx-Slave-1"
        ComputerName="lxjnk-slave-1"
        Size="Standard_DS1_v2"
        Type="Linux"
        Publisher="Canonical"
        Offer="UbuntuServer"
        skus="16.04-LTS"
        StorageType="Premium_LRS"
        DiskName="Vm1_Disk"
        DiskSize=40
        NetworkName="ContinuousIntegration_Network"
        SubnetName="Back"
        SshPublicKey = (Get-Content "$env:USERPROFILE\.ssh\.azureuser.pub")    
        Extensions = @{
            "JavaJre" = $AzureRmVMExtensionsUbuntu.JavaJre
            "Ansible" = $AzureRmVMExtensionsUbuntu.Ansible
        }    

    }
    New-Object -TypeName PsObject -Property @{
        Name="ci-win-Slave-1"
        ComputerName="winjnk-slave-1"
        Size="Standard_DS1_v2"
        Type="Windows"
        Publisher="MicrosoftWindowsServer"
        Offer="WindowsServer"
        skus="2016-Datacenter-smalldisk"
        StorageType="Standard_LRS"
        DiskName="Vm1_Disk"
        DiskSize=40
        NetworkName="ContinuousIntegration_Network"
        SubnetName="Back"
        Extensions = @{
            "Winrm" = $AzureRmVMExtensionsWindows.WinrmActivation
        }    
    }
    New-Object -TypeName PsObject -Property @{
        Name="ci-lx-admin"
        ComputerName="lx-ci-admin"
        Size="Standard_DS1_v2"
        Type="Linux"
        Publisher="Canonical"
        Offer="UbuntuServer"
        skus="16.04-LTS"
        StorageType="Premium_LRS"
        DiskName="Vm1_Disk"
        DiskSize=40
        NetworkName="ContinuousIntegration_Network"
        SubnetName="Services"
        SshPublicKey = (Get-Content "$env:USERPROFILE\.ssh\.azureuser.pub")
        EnablePublicIp = $true
        Extensions = @{
            "Ansible" = $AzureRmVMExtensionsUbuntu.Ansible
        }    
    }

)




# $global:firewallRules = @()
# $firewallRules.Add("Vm2", @($FirewallExistingRules.allowSsh))

# $FirewallAllowSsh = Get-NetworkRuleDefinition -property @{
#           Name="AllowSsh"
#           Protocol="Tcp"
#           Direction="Inbound"
#           Priority=1000
#           SourceAddressPrefix="*"
#           SourcePortRange="*"
#           DestinationAddressPrefix="*"
#           DestinationPortRange=22
#           Access="Allow"
#       }


# $FirewallAllowSsh = @{
#     Name="AllowSsh"
#     Protocol="Tcp"
#     Direction="Inbound"
#     Priority=1000
#     SourceAddressPrefix="*"
#     SourcePortRange="*"
#     DestinationAddressPrefix="*"
#     DestinationPortRange=22
#     Access="Allow"
# }

# New-AzureRmNetworkSecurityRuleConfig @FirewallAllowSsh

# # Create an inbound network security group rule for port 22
# $nsgRuleSSH = New-AzureRmNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleSSH  -Protocol Tcp `
#   -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
#   -DestinationPortRange 22 -Access Allow

