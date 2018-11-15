#peering 2 vnet : https://docs.microsoft.com/fr-fr/azure/virtual-network/tutorial-connect-virtual-networks-portal
#DNS : https://docs.microsoft.com/fr-fr/azure/dns/

Function Set-VirtualNetwork
{
    [cmdletbinding(DefaultParameterSetName="none")]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location,
    
        [Parameter(Mandatory=$true)]
        [Object]$Network
    
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

        #Todo : Check variables

        #Retrieve current configuration
        Trace-Message -Message ("Try to retrieve Virtual Network '{0}' in resourceGroup '{1}'" -f $Network.Name, $ResourceGroupName)
        $vnet = Get-AzureRmVirtualNetwork   -Name $Network.Name `
                                            -ResourceGroupName $resourceGroupName `
                                            -ErrorAction SilentlyContinue

        if ($null -ne $vnet)
        {

            Trace-Message -Message ("Virtual Network '{0}' in resourceGroup '{1}' already exist, it will be updated" -f $Network.Name, $ResourceGroupName)
            #Add subnet Objects if required
            #Todo : Can be better to do with intersection
            $Network.Subnets | ForEach-Object {
                
                $newSubnet = $_
                $existingSubnet = ($vnet.Subnets | Where-Object {$_.Name -eq $newSubnet.Name})


                if ($existingSubnet -eq $null)
                {
                    Add-AzureRmVirtualNetworkSubnetConfig -Name $newSubnet.Name `
                                                        -VirtualNetwork $vnet `
                                                        -AddressPrefix $newSubnet.AddressPrefix


                }
            }

            Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
        }
        else
        {
            #Create the subnet Objects
            Trace-Message -Message ("Virtual Network '{0}' in resourceGroup '{1}' doesn't exist, it will be created" -f $Network.Name, $ResourceGroupName)
            $subnets=@()
            $Network.Subnets | ForEach-Object {
                $subnet = New-AzureRmVirtualNetworkSubnetConfig -Name $_.Name `
                                                                -AddressPrefix $_.AddressPrefix

                $subnets += $subnet                                                     
            }

            $vnet = New-AzureRmVirtualNetwork -Name $Network.Name -ResourceGroupName $resourceGroupName `
                                        -Location $location `
                                        -AddressPrefix $Network.AddressPrefix `
                                        -Subnet $subnets

        }

        Write-Output $vnet                                  
   }
}

Function Get-NetworkSubNet
{
    [cmdletbinding(DefaultParameterSetName="none")]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location,
    
        [Parameter(Mandatory=$true)]
        [String]$NetworkName,

        [Parameter(Mandatory=$true)]
        [String]$SubnetName

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
        $vnet = Get-AzureRmVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName

        $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet

        Write-Output $subnet
        
    }
}