$script:MESF_AzureContext=$null

<#
.Description
Initialize the workspace

.Example
Test-Resource -Name

.Notes
The output is a Boolean
#>
function Initialize-MESFAzureWorkspace
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute( "PSAvoidDefaultValueForMandatoryParameter", "" )]
    [CmdletBinding( DefaultParameterSetName = 'Default', SupportsShouldProcess=$false )]
    [OutputType( [Boolean] )]
    param(

        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $LocalSecureVaultPath,

        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $ContextFileName
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
        #Create Folder if doesn't exists
        if (-not (Test-Path -Path $LocalSecureVaultPath -PathType Container))
        {
            Trace-Message "Create new directory : '$LocalSecureVaultPath'"  -InvocationMethod $MyInvocation.MyCommand
            New-Item -Path $LocalSecureVaultPath -ItemType Directory | Out-Null
            Trace-Message "New directory '$LocalSecureVaultPath' created"  -InvocationMethod $MyInvocation.MyCommand
        }

        #Create the MESF_AzureContext for the first usage
        $contextFilePath = [System.IO.Path]::Combine($LocalSecureVaultPath, $ContextFileName)
        if (-not (Test-Path -Path $contextFilePath -PathType Leaf))
        {
            Trace-Message "Create new context File : '$contextFilePath'"  -InvocationMethod $MyInvocation.MyCommand
            $script:MESF_AzureContext = @{
                Users=@{}
                ServicePrincipals=@{}
            }

            $script:MESF_AzureContext | export-CliXml -Path $contextFilePath
            Trace-Message "New Contex file '$contextFilePath' created"  -InvocationMethod $MyInvocation.MyCommand
        }
        else
        {
            Trace-Message "Load Contex file '$contextFilePath'"  -InvocationMethod $MyInvocation.MyCommand
            $script:MESF_AzureContext = Import-CliXml -Path $contextFilePath
        }
    }
}

<#
.Description
Assert context has been loaded.

.Example


.Notes

#>
function Assert-MESFAzureContext
{
    [CmdletBinding()]
    param()
    process
    {
        #IF current context is null, we have to retrieve it
        #If Workspace doesn't exist , we will creat eit for the first use
        if ($null -eq $script:MESF_AzureContext)
        {
            Trace-Message "First load of Contex file '$contextFilePath'"  -InvocationMethod $MyInvocation.MyCommand

            $localSecureVaultPath = "$($ENV:USERPROFILE)\.mesf_azure"
            $contextFileName = "MESF_Context.xml"
            Initialize-MESFAzureWorkspace -LocalSecureVaultPath $localSecureVaultPath `
                                          -ContextFileName $contextFileName

            if ($null -eq $script:MESF_AzureContext)
            {
                Throw new-Object System.Exception "Unable to load the MESF Context"
            }
        }
    }
}

<#
.Description
Save context.

.Example


.Notes

#>
function Save-MESFAzureContext
{
    [CmdletBinding()]
    param()
    process
    {
        #IF current context is null, we have to retrieve it
        #If Workspace doesn't exist , we will creat eit for the first use
        if (-not($null -eq $script:MESF_AzureContext))
        {
            $localSecureVaultPath = "$($ENV:USERPROFILE)\.mesf_azure"
            $contextFileName = "MESF_Context.xml"
            $contextFilePath = [System.IO.Path]::Combine($LocalSecureVaultPath, $ContextFileName)

            Trace-Message "Save Contex file '$contextFilePath'"  -InvocationMethod $MyInvocation.MyCommand
            $script:MESF_AzureContext | export-CliXml -Path $contextFilePath
        }
        else
        {
            Write-warning "MESF Azure Context is null, It can't be saved"
        }
    }
}

