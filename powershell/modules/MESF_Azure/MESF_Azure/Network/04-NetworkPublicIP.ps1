Function Set-MESFAzPublicIpAddress
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
        [String]$DomainNameLabel,

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


        Trace-Message -Message ("Try to retrieve Public IP '{0}' in resourceGroup '{1}'" -f $Name, $ResourceGroupName) -InvocationMethod $MyInvocation.MyCommand
        $publicIp = Get-AzPublicIpAddress -Name $Name `
                                          -ResourceGroupName $ResourceGroupName `
                                          -ErrorAction SilentlyContinue


        if ($null -eq $publicIp)
        {
            Trace-Message -Message ("Public IP '{0}' in resourceGroup '{1}' doesn't exist, it will be created" -f $Name, $ResourceGroupName) -InvocationMethod $MyInvocation.MyCommand

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

            if (![String]::IsNullOrEmpty($DomainNameLabel))
            {
                $publicIpParams.Add("DomainNameLabel", $DomainNameLabel)
            }

            $publicIp = New-AzPublicIpAddress @publicIpParams -ErrorAction Stop
        }

        write-output $publicIp

    }
}