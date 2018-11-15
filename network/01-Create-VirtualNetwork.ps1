param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$Location,

    [Parameter(Mandatory=$true)]
    [Object]$Network

)

#Todo : Check variables

#Retrieve current configuration
$nw = Get-AzurermResource `
  | Where-Object {$_.ResourceType -eq "Microsoft.Network/virtualNetworks" -and $_.Location -eq $location }

if ($nw -ne $null)
{
    $vnet = Get-AzureRmVirtualNetwork   -Name $Network.Name `
                                        -ResourceGroupName $resourceGroupName

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
