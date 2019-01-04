Function Set-PublicIP
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location,
    
        [Parameter(Mandatory=$true)]
        [String]$Name,

        [Parameter(Mandatory=$false)]
        [String]$Alias,

        [ValidateSet("Static", "Dynamic")]
        [Parameter(Mandatory=$false)]
        [String]$AllocationMethod="Static"

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


        Trace-Message -Message ("Try to retrieve Public IP '{0}' in resourceGroup '{1}'" -f $Name, $ResourceGroupName)
        $publicIp = Get-AzureRmPublicIpAddress -Name $Name `
                                               -ResourceGroupName $ResourceGroupName `
                                               -ErrorAction SilentlyContinue
                                               

        if ($null -eq $publicIp)
        {
            Trace-Message -Message ("Public IP '{0}' in resourceGroup '{1}' doesn't exist, it will be created" -f $Name, $ResourceGroupName)

            if ($null -eq $IdleTimeoutInMinutes)
            {
                $IdleTimeoutInMinutes = 4
            }

            $publicIpParams = @{
                Name = $Name
                ResourceGroupName = $ResourceGroupName
                Location = $Location
                AllocationMethod = $AllocationMethod                
                IdleTimeoutInMinutes = $IdleTimeoutInMinutes
            }

            if (![String]::IsNullOrEmpty($Alias))
            {
                $publicIpParams.Add("DomainNameLabel", $Alias)
            }

            $publicIp = New-AzureRmPublicIpAddress @publicIpParams -ErrorAction Stop
        }

        write-output $publicIp

    }        
}