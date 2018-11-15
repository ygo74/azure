function Set-NetworkWatcher 
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location
    )
    
    process
    {
        $nw = Get-AzurermResource `
          | Where-Object {$_.ResourceType -eq "Microsoft.Network/networkWatchers" -and $_.Location -eq $location }
        
        if ($null -eq $nw)
        {
            $networkWatcher = New-AzureRmNetworkWatcher -Name "NetworkWatcher_$resourceGroupName" `
                              -ResourceGroupName $resourceGroupName `
                              -Location $location
        }  
        else
        {
            $networkWatcher = Get-AzureRmNetworkWatcher `
            -Name $nw.Name `
            -ResourceGroupName $nw.ResourceGroupName      
        }
        
        $networkWatcher    
    }            
}
