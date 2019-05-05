Function Set-ContainerRegistry
{
    [cmdletbinding(DefaultParameterSetName="none", SupportsShouldProcess=$true)]
    Param(
        [Parameter(Mandatory=$true)]
        [Object]$Registry
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

        #search params
        $searchParams = Get-ParamsFromObjectToCommand -CommandName Get-AzContainerRegistry -Object $registry
        Trace-Message -Message ("Search Container Registry '{0}' in resourceGroup '{1}'" -f $searchParams.Name, $searchParams.ResourceGroupName) -InvocationMethod $MyInvocation.MyCommand
        $azRegistry = Get-AzContainerRegistry @searchParams -ErrorAction SilentlyContinue

        $whatif = $PSBoundParameters.ContainsKey('WhatIf')

        if ($null -eq $azRegistry) {
            Trace-Message -Message ("Container Registry '{0}' in resourceGroup '{1}' doesn't exist, it will be created" -f $searchParams.Name, $searchParams.ResourceGroupName) `
                          -InvocationMethod $MyInvocation.MyCommand

            $commandParams = Get-ParamsFromObjectToCommand -CommandName New-AzContainerRegistry -Object $registry
            $commandParams.Add("Whatif",$whatif)

            #Create the registry
            $newRegistry = New-AzContainerRegistry @commandParams

        }
        else {
            Trace-Message -Message ("Container Registry '{0}' in resourceGroup '{1}' Already exist, it will be updated if data is different" -f $searchParams.Name, $searchParams.ResourceGroupName) `
                          -InvocationMethod $MyInvocation.MyCommand
            Trace-Message -Message ("Container Registry '{0}' update is not yet implemented" -f $searchParams.Name, $searchParams.ResourceGroupName) `
                          -InvocationMethod $MyInvocation.MyCommand

        }

        #Add whatif management
        if ($PSBoundParameters.ContainsKey('WhatIf'))
        {
            return $null
        }
        Get-AzContainerRegistry @searchParams
    }
}
