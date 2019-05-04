<#
.Description
Register MESF Azure Service Principal and save its password in the context

.Example

.Notes
#>
Function Register-MESFAzureServicePrincipal
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$false, Position=0)]
        [String]
        $Application
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

        #Prepare Information for service Principal Creation
        Add-Type -Assembly System.Web
        $password = [System.Web.Security.Membership]::GeneratePassword(16,3)
        $securePassword = ConvertTo-SecureString -Force -AsPlainText -String $password

        $servicePrincipal = New-Object -TypeName PSObject -Property @{
            ApplicationName = $Application
            Password = $securePassword
        }

        #Create The application
        $identifierUris = ("http://azure/{0}" -f $Application).ToLower()
        $azureApplication = Get-AzureRmADApplication -DisplayName $Application -ErrorAction SilentlyContinue
        if ($null -eq $azureApplication)
        {
            Trace-Message -Message ("Create new Application '{0}' with identifierUris '{1}'" -f $Application, $identifierUris)
            $azureApplication = New-AzureRmADApplication -DisplayName $Application -IdentifierUris $identifierUris
        }

        #Create The Service principal Name
        $azureServicePrincipal = Get-AzureRmADServicePrincipal -ApplicationId $azureApplication -ErrorAction SilentlyContinue
        if ($null -eq $azureServicePrincipal)
        {
            Trace-Message -Message ("Create new ServicePrincipal for application '{0}'" -f $Application)

            $azureServicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $azureApplication.ApplicationId `
                                   -Password securePassword

            #Save the service Principal Name data
            Add-ServicePrincipalToContext -ServicePrincipal $servicePrincipal
        }

        #return the Azure service Principal Name
        $azureServicePrincipal
    }
}

<#
.Description
Register MESF Azure User and save its password in the context

.Example

.Notes
#>
Function Register-MESFAzureUser
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$false, Position=0)]
        [String]
        $Name,

        [Parameter(Mandatory=$true,ValueFromPipeline=$false, Position=1)]
        [String]
        $UserPrincipalName,

        [Parameter(Mandatory=$true,ValueFromPipeline=$false, Position=2)]
        [String]
        $DisplayName

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

        #Prepare Information for service Principal Creation
        Add-Type -Assembly System.Web
        $password = [System.Web.Security.Membership]::GeneratePassword(16,3)
        $securePassword = ConvertTo-SecureString -Force -AsPlainText -String $password

        $user = New-Object -TypeName PSObject -Property @{
            Name              = $Name
            UserPrincipalName = $UserPrincipalName
            DisplayName       = $DisplayName
            Password          = $securePassword
        }

        #Create The user
        $azureUser = Get-AzureRmADUser -UserPrincipalName $UserPrincipalName -ErrorAction SilentlyContinue
        if ($null -eq $azureUser)
        {
            Trace-Message -Message ("Create new User '{0}' with DisplayName '{1}'" -f $UserPrincipalName, $DisplayName)
            $azureUser = New-AzureRmADUser -UserPrincipalName $UserPrincipalName `
                             -MailNickname $Name `
                             -DisplayName $DisplayName -Password $securePassword `
                             -ErrorAction Stop

            #Save the service Principal Name data
            Add-UserToContext -User $user
        }

        #return the Azure service Principal Name
        $azureUser
    }
}


Function Get-UserCredential
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "")]
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(ParameterSetName="EncryptedPassword", Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [String]
        $KeyFilePath,

        [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [String]
        $UserName,

        [Parameter(ParameterSetName="EncryptedPassword", Mandatory=$true)]
        [String]
        $EncryptedPassword,

        [Parameter(ParameterSetName="ClearPassword", Mandatory=$true)]
        [String]
        $ClearPassword

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

        if ($PSCmdlet.ParameterSetName -eq 'EncryptedPassword')
        {

            $key = Get-Content -Path $KeyFilePath

            $userCredential = New-Object -TypeName System.Management.Automation.PSCredential `
                              -ArgumentList $UserName, ($EncryptedPassword | ConvertTo-SecureString -Key $key)

        }
        else
        {
            $userCredential = New-Object -TypeName System.Management.Automation.PSCredential `
                              -ArgumentList $UserName, ($ClearPassword | ConvertTo-SecureString -AsPlainText -Force)

        }

        #return the user Credential
        $userCredential

    }
}


Function Register-UserCredential
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [String]
        $LocalSecureVaultPath,

        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [String]
        $KeyFilePath,

        [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [String]
        $UserName
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

        #Load key file Path
        Trace-Message "Read key file '$KeyFilePath'"
        $key = Get-Content -Path $KeyFilePath

        #Read Vault File if exists
        $vaultFilePath = [System.IO.Path]::Combine($LocalSecureVaultPath, ".Vault")
        if (Test-Path -Path $vaultFilePath -PathType Leaf)
        {
            Trace-Message "Read existing Vault Data '$vaultFilePath'"
            $vaultData = Get-Content -Path $vaultFilePath | ConvertFrom-Csv
        }
        else
        {
            $vaultData = @()
        }


        $password = Read-Host -AsSecureString -Prompt "Please, enter the password for encryption"

        $encryptedPassword = ConvertFrom-SecureString -SecureString $password -Key $key

        $user = New-Object -TypeName psobject -Property @{
            user=$UserName
            password=$encryptedPassword
        }

        $vaultData += $user
        Trace-Message "Write Vault Data '$vaultFilePath'"
        $vaultData | ConvertTo-Csv | Set-Content -Path $vaultFilePath

    }
}


