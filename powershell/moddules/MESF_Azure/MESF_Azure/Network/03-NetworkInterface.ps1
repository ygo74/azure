function Set-NetworkInterface
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [Microsoft.Azure.Commands.Network.Models.PSSubnet]$Subnet,
        
        [Parameter(Mandatory=$false)]
        [string]$PublicIpAddressId,

        [Parameter(Mandatory=$false)]
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
        Trace-Message -Message ("Try to retrieve Network Interface '{0}' in resourceGroup '{1}'" -f $Name, $ResourceGroupName)
        $nic = Get-AzureRmNetworkInterface  -Name $Name `
                                            -ResourceGroupName $ResourceGroupName `
                                            -ErrorAction SilentlyContinue

        if ($nic -eq $null)
        {

            Trace-Message -Message ("Network Interface '{0}' in resourceGroup '{1}' doesn't exist, it will be created" -f $Name, $ResourceGroupName)
            $networkInterfacesDefinition = @{
                Name = $Name
                ResourceGroupName = $ResourceGroupName
                Location = $Location
                SubnetId = $Subnet.Id
            }
            
            if (![String]::IsNullOrEmpty($PublicIpAddressId))
            {
               $networkInterfacesDefinition.Add("PublicIpAddressId", $PublicIpAddressId) 
            }

            $nic = New-AzureRmNetworkInterface @networkInterfacesDefinition
        }
        else {
            if ($nic.IpConfigurations[0].Subnet.Id -ne $Subnet.Id)
            {
                Trace-Message -Message ("Network Interface '{0}' in resourceGroup '{1}' will move to subnet {2}" -f $Name, $ResourceGroupName, $Subnet.Id)
                $nic.IpConfigurations[0].Subnet.Id = $Subnet.Id    
            }

            if (($nic.IpConfigurations[0].PublicIpAddressId -ne $PublicIpAddressId) `
                -and (![String]::IsNullOrEmpty($PublicIpAddressId)))
            {
                Trace-Message -Message ("Network Interface '{0}' in resourceGroup '{1}' will be associate to other PublicIp '{2}'" -f $Name, $ResourceGroupName, $PublicIpAddressId)
                $nic.IpConfigurations[0].PublicIpAddress.Id = $PublicIpAddressId
            }

            Set-AzureRmNetworkInterface -NetworkInterface $nic | Out-Null            
        }

        Write-Output $nic
    }
}    
