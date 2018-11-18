function Initialize-Workspace
{
    <#
        .Description
        Initialize the workspace

        .Example
        Test-Resource -Name

        .Example

        .Notes
        The output is a Boolean
    #>
#    [Diagnostics.CodeAnalysis.SuppressMessageAttribute( "PSAvoidDefaultValueForMandatoryParameter", "" )]
    [CmdletBinding( DefaultParameterSetName = 'Default', SupportsShouldProcess=$false )]
    [OutputType( [Boolean] )]
    param(

        [Parameter(Mandatory = $false, Position = 0)]
        [string]
        $LocalSecureVaultPath="$($ENV:USERPROFILE)\.mesf_azure",

        [Parameter(Mandatory = $false, Position = 1)]
        [string]
        $KeyFileName=".$($ENV:USERNAME)"
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
            if (-not (Test-Path -Path $LocalSecureVaultPath -PathType Container))
            {
                Trace-Message "Create new directory : '$LocalSecureVaultPath'"
                New-Item -Path $LocalSecureVaultPath -ItemType Directory | Out-Null
                Trace-Message "New directory '$LocalSecureVaultPath' created"
            }

            New-KeyFile -Path $LocalSecureVaultPath -KeyfileName $KeyFileName
        }
        catch
        {
        }
    }

}
