function Set-MESFAzNetworkInterface
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
        [String]$SubnetId,

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
        $nic = Get-AzNetworkInterface  -Name $Name `
                                       -ResourceGroupName $ResourceGroupName `
                                       -ErrorAction SilentlyContinue

        if ($null -eq $nic)
        {

            Trace-Message -Message ("Network Interface '{0}' in resourceGroup '{1}' doesn't exist, it will be created" -f $Name, $ResourceGroupName)
            $networkInterfacesDefinition = @{
                Name = $Name
                ResourceGroupName = $ResourceGroupName
                Location = $Location
                SubnetId = $SubnetId
            }

            if (![String]::IsNullOrEmpty($PublicIpAddressId))
            {
               $networkInterfacesDefinition.Add("PublicIpAddressId", $PublicIpAddressId)
            }

            $nic = New-AzNetworkInterface @networkInterfacesDefinition
        }
        else {
            if ($nic.IpConfigurations[0].Subnet.Id -ne $SubnetId)
            {
                Trace-Message -Message ("Network Interface '{0}' in resourceGroup '{1}' will move to subnet {2}" -f $Name, $ResourceGroupName, $SubnetId)
                $nic.IpConfigurations[0].Subnet.Id = $SubnetId
            }

            if (($nic.IpConfigurations[0].PublicIpAddressId -ne $PublicIpAddressId) `
                -and (![String]::IsNullOrEmpty($PublicIpAddressId)))
            {
                Trace-Message -Message ("Network Interface '{0}' in resourceGroup '{1}' will be associate to other PublicIp '{2}'" -f $Name, $ResourceGroupName, $PublicIpAddressId)
                $nic.IpConfigurations[0].PublicIpAddress.Id = $PublicIpAddressId
            }

            Set-AzNetworkInterface -NetworkInterface $nic | Out-Null
        }

        Write-Output $nic
    }
}
