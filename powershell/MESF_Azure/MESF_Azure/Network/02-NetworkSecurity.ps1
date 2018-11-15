
# # Create an inbound network security group rule for port 22
# $nsgRuleSSH = New-AzureRmNetworkSecurityRuleConfig -Name myNetworkSecurityGroupRuleSSH  -Protocol Tcp `
#   -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
#   -DestinationPortRange 22 -Access Allow

# # Create a network security group
# $nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $resourceGroup -Location $location `
#   -Name myNetworkSecurityGroup -SecurityRules $nsgRuleSSH

$global:FirewallDefaultRules=@{
    allowSsh = @{
        Name="AllowSsh"
        Protocol="Tcp"
        Direction="Inbound"
        Priority=1000
        SourceAddressPrefix="*"
        SourcePortRange="*"
        DestinationAddressPrefix="*"
        DestinationPortRange=22
        Access="Allow"
    }
    allowRdp = @{
        Name="allowRdp"
        Protocol="Tcp"
        Direction="Inbound"
        Priority=1000
        SourceAddressPrefix="*"
        SourcePortRange="*"
        DestinationAddressPrefix="*"
        DestinationPortRange=3389
        Access="Allow"
    }
    allowWinrm = @{
        Name="allowWinrm"
        Protocol="Tcp"
        Direction="Inbound"
        Priority=1000
        SourceAddressPrefix="*"
        SourcePortRange="*"
        DestinationAddressPrefix="*"
        DestinationPortRange=5985
        Access="Allow"
    }
    allowWinrms = @{
        Name="allowWinrms"
        Protocol="Tcp"
        Direction="Inbound"
        Priority=1000
        SourceAddressPrefix="*"
        SourcePortRange="*"
        DestinationAddressPrefix="*"
        DestinationPortRange=5986
        Access="Allow"
    }
}


function ConvertTo-AzureRMSecurityRule
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true,  ValueFromPipeline=$true)]
        [NetworkRule]$InputObject
    )

    #Check Attribute defqult Value
    $description = $InputObject.Description
    if ([String]::IsNullOrEmpty($description))
    {
        $description = "Network Secuirty rule : {0}" -f $InputObject.Name
    }

    # New-AzureRmNetworkSecurityRuleConfig -Name     $InputObject.Name `
    #                     -Description               $description `
    #                     -Protocol                  $InputObject.Protocol `
    #                     -Direction                 $InputObject.Direction `
    #                     -Priority                  $InputObject.Priority `
    #                     -SourcePortRange           $InputObject.SourcePortRange `
    #                     -SourceAddressPrefix       $InputObject.SourceAddressPrefix `
    #                     -DestinationPortRange      $InputObject.DestinationPortRange `
    #                     -DestinationAddressPrefix  $InputObject.DestinationAddressPrefix

    $properties = @{}
    
    $InputObject.Psobject.Properties | ForEach-Object {

        if (($_.Name -eq "Description") -and ([String]::IsNullOrEmpty($_.Value)))
        {
            $properties.Add($_.Name, "rule for $($InputObject.Name)")
        }
        else {
            $properties.Add($_.Name, $_.Value)
        }

        
    }

    New-AzureRmNetworkSecurityRuleConfig @properties

}        

function Set-NetworkSecurityGroup
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [NetworkRule[]]$Rules
    )
    begin
    {
        $watch = Trace-StartFunction -InvocationMethod $MyInvocation.MyCommand
    }

    end
    {
        Trace-EndFunction -InvocationMethod $MyInvocation.MyCommand -watcher $watch
    }
    Process
    {

        $securityRules = @()
        $Rules | ConvertTo-AzureRMSecurityRule | ForEach-Object {
            $securityRules +=  $_
        }
      
        $securityGroup = Get-AzureRmNetworkSecurityGroup -Name $Name `
                             -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

        if ($null -eq $securityGroup)
        {
            Trace-Message -Message ("Security group '{0}' in resourceGroup '{1}' doesn't exist, it will be created")
            $securityGroup = New-AzureRmNetworkSecurityGroup -Name $Name `
                                -ResourceGroupName $ResourceGroupName -Location $Location `
                                -SecurityRules $securityRules
        }
        else {

            Trace-Message -Message ("Security group '{0}' in resourceGroup '{1}' already exist, it will be updated")
            $securityGroup.SecurityRules = $securityRules
            Set-AzureRmNetworkSecurityGroup -NetworkSecurityGroup $securityGroup
        }

        write-output $securityGroup

    }
}

#http://blog.e-novatic.fr/application-security-group-dans-azure/
function Set-ApplicationSecurityGroup
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [NetworkRule[]]$Rules
    )
    begin
    {
        $watch = Trace-StartFunction -InvocationMethod $MyInvocation.MyCommand
    }

    end
    {
        Trace-EndFunction -InvocationMethod $MyInvocation.MyCommand -watcher $watch
    }
    Process
    {
        Register-AzureRmProviderFeature   -FeatureName AllowApplicationSecurityGroups -ProviderNamespace Microsoft.Network
        Register-AzureRmResourceProvider  -ProviderNamespace Microsoft.Network

        #Create ASG
        $webASG  =  new-AzureRmApplicationSecurityGroup  -ResourceGroupName $ResourceGroupName -Name $Name -Location $Location

        #Create NGS avec AGS
        $nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName RGTEST -Location westurope -Name ASGTEST `
                      -SecurityRules $webRule,$sqlRule                       

        #Assign NGS to subnet
        $vnet = Get-AzureRmVirtualNetwork -Name ASGTEST -ResourceGroupName RGTEST
        Set-AzureRmVirtualNetworkSubnetConfig -Name default -VirtualNetwork $vnet `
                      -NetworkSecurityGroupId $nsg.Id -AddressPrefix '10.1.0.0/16'

        Set-AzureRmVirtualNetwork -VirtualNetwork $vnet                              

        #Add NICS to AGS
        $webNic = Get-AzureRmNetworkInterface -Name NICNAME -ResourceGroupName RGTEST
        $webNic.IpConfigurations[0].ApplicationSecurityGroups = $webASG
        Set-AzureRmNetworkInterface -NetworkInterface $webNic
        
        $sqlNic = Get-AzureRmNetworkInterface -Name NICNAME -ResourceGroupName RGTEST
        $sqlNic.IpConfigurations[0].ApplicationSecurityGroups = $sqlASG
        Set-AzureRmNetworkInterface -NetworkInterface $sqlNic        
                      
    }
}