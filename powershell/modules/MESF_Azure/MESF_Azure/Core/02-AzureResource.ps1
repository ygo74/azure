<#
.Description
Test if a Resource exist in your Azure workspace

.Example
Test-Resource -Name

.Example

.Notes
The output is a Boolean
#>
function Test-Resource
{
    [CmdletBinding( DefaultParameterSetName = 'Default', SupportsShouldProcess=$false )]
    [OutputType( [Boolean] )]
    param(

        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $ResourceName,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $ResourceType,

        [Parameter(Mandatory = $true, Position = 2)]
        [string]
        $ResourceGroupName
    )

    begin
    {
        $watch = Trace-StartFunction -InvocationMethod $MyInvocation.MyCommand
    }

    end
    {
        Trace-EndFunction -InvocationMethod $MyInvocation.MyCommand -watcher $watch
    }

    process
    {
        try
        {
            $azResource = Get-AzResource -ResourceType $ResourceType `
                                -ResourceGroupName $ResourceGroupName `
                          | Where-Object {$_.ResourceName -eq $ResourceName}

            return ($null -ne $azResource)
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError( $PSitem )
        }
    }

}
#Export-ModuleMember -Function Test-Resource



function Set-ResourceGroup
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,

        [Parameter(Mandatory=$true)]
        [string]$Location
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

        #Create the resource group
        $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -Location $location -ErrorAction SilentlyContinue

        if ($null -eq $resourceGroup)
        {
            Trace-Message -Message ("Resource Group '{0}' doesn't exist, it will be created" -f $ResourceGroupName)
            $resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location
        }

        $resourceGroup
    }
}