$global:Location = "westeurope"
$global:ResourceGroupName = "Ansible-lab"
$global:Author = "YGO74"

$global:virtualNetworks=@(
    New-Object -TypeName PsObject -Property @{
            Name="Ansible-lab_Network"
            AddressPrefix="10.1.0.0/16"
            Subnets=@(
                New-Object -TypeName PsObject -Property @{
                    Name="Ansible-lab_Subnet_front"
                    AddressPrefix="10.1.1.0/24"
                }
                New-Object -TypeName PsObject -Property @{
                    Name="Ansible-lab_Subnet_Services"
                    AddressPrefix="10.1.3.0/24"
                }
                New-Object -TypeName PsObject -Property @{
                    Name="Ansible-lab_Subnet_back"
                    AddressPrefix="10.1.2.0/24"
                }
                New-Object -TypeName PsObject -Property @{
                    Name="Ansible-lab_Subnet_admin"
                    AddressPrefix="10.1.4.0/24"
                }
            )
        }
)

$Global:PublicIps=@{
    "Vm2" = New-Object -TypeName psobject -Property @{
        Alias = ("{0}-vm2" -f $ResourceGroupName.ToLower())
        Name = ("{0}_publicIp_vm2" -f $ResourceGroupName , $VirtualMachine.Name)
    }
}


$global:VirtualMachines=@(
        New-Object -TypeName PsObject -Property @{
            Name="Vm1"
            ComputerName="srv1"
            Size="Standard_DS1_v2"
            Type="Windows"
            Publisher="MicrosoftWindowsServer"
            Offer="WindowsServer"
            #skus="2012-R2-Datacenter-smalldisk"
            skus="2016-Datacenter-smalldisk"
            StorageType="Standard_LRS"
            DiskName="Vm1_Disk"
            DiskSize=40
            NetworkName="Ansible-lab_Network"
            SubnetName="Ansible-lab_Subnet_front"
        }
        New-Object -TypeName PsObject -Property @{
            Name="Vm2"
            ComputerName="srv2"
            Size="Standard_DS1_v2"
            Type="Linux"
            Publisher="Canonical"
            Offer="UbuntuServer"
            skus="16.04-LTS"
            StorageType="Premium_LRS"
            DiskName="Vm2_Disk"
            DiskSize=40
            NetworkName="Ansible-lab_Network"
            SubnetName="Ansible-lab_Subnet_front"
            SshPublicKey = (Get-Content "$env:USERPROFILE\.ssh\.azureuser.pub")    
            PublicIp = $PublicIp.Vm2
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

