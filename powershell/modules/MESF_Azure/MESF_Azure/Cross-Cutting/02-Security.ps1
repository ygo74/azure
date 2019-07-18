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
        $ApplicationName,

        [Parameter(Mandatory=$false,ValueFromPipeline=$false, Position=1)]
        [Switch]
        $SynchronizeAzureVault,

        [Parameter(Mandatory=$false,ValueFromPipeline=$false, Position=2)]
        [Switch]
        $ResetPassword


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
            ApplicationName = $ApplicationName
            Password = $securePassword
        }

        #Create The application
        $identifierUris = ("http://azure/{0}" -f $ApplicationName).ToLower()
        $azureApplication = Get-AzADApplication -DisplayName $ApplicationName -ErrorAction SilentlyContinue
        if ($null -eq $azureApplication)
        {
            Trace-Message -Message ("Create new Application '{0}' with identifierUris '{1}'" -f $ApplicationName, $identifierUris) -InvocationMethod $MyInvocation.MyCommand
            $azureApplication = New-AzADApplication -DisplayName $ApplicationName -IdentifierUris $identifierUris -ErrorAction Stop
            $azureApplicationCredential = New-AzADAppCredential -ApplicationId $azureApplication.ApplicationId -Password $securePassword -EndDate (Get-Date -Year 2024)
        }
        else {
            if ($ResetPassword) {
                Trace-Message -Message ("Reset Application password for application '{0}'" -f $ApplicationName)  -InvocationMethod $MyInvocation.MyCommand
                Remove-AzADAppCredential -ApplicationId $azureApplication.ApplicationId -Force
                New-AzADAppCredential -ApplicationId $azureApplication.ApplicationId -Password $securePassword -EndDate (Get-Date -Year 2024)
            }
        }

        #Create The Service principal Name
        $azureServicePrincipal = Get-AzADServicePrincipal -ApplicationId $azureApplication.ApplicationId -ErrorAction SilentlyContinue
        if ($null -eq $azureServicePrincipal)
        {
            Trace-Message -Message ("Create new ServicePrincipal for application '{0}'" -f $ApplicationName) -InvocationMethod $MyInvocation.MyCommand

            $credentials = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{
                StartDate=Get-Date;
                EndDate=Get-Date -Year 2024;
                Password=$password
            }

            $azureServicePrincipal = New-AzADServicePrincipal -ApplicationId $azureApplication.ApplicationId `
                                                              -PasswordCredential $credentials

            #Save the service Principal Name data
            Set-MESFServicePrincipalToContext -ServicePrincipal $servicePrincipal
        }
        else {
            if ($ResetPassword) {
                Trace-Message -Message ("Reset ServicePrincipal password for application '{0}'" -f $ApplicationName)  -InvocationMethod $MyInvocation.MyCommand
                Remove-AzADSpCredential -ObjectId $azureServicePrincipal.Id -Force
                $newSpCredential = New-AzADSpCredential -ObjectId $azureServicePrincipal.Id -EndDate (Get-Date -Year 2024)

                $servicePrincipal.Password = $newSpCredential.Secret

                #Save the service Principal Name data
                Set-MESFServicePrincipalToContext -ServicePrincipal $servicePrincipal
            }
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
        $azureUser = Get-AzADUser -UserPrincipalName $UserPrincipalName -ErrorAction SilentlyContinue
        if ($null -eq $azureUser)
        {
            Trace-Message -Message ("Create new User '{0}' with DisplayName '{1}'" -f $UserPrincipalName, $DisplayName)
            $azureUser = New-AzADUser -UserPrincipalName $UserPrincipalName `
                             -MailNickname $Name `
                             -DisplayName $DisplayName -Password $securePassword `
                             -ErrorAction Stop

            #Save the service Principal Name data
            Set-MESFUserToContext -User $user
        }

        #return the Azure service Principal Name
        $azureUser
    }
}

function Get-MESFClearPAssword
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [System.Security.SecureString]
        $Password
    )
    process
    {
        $UnsecurePassword = (New-Object PSCredential "user",$Password).GetNetworkCredential().Password
        $UnsecurePassword
    }
}


Function Remove-MESFAzureServicePrincipal
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$false, Position=0)]
        [String]
        $ApplicationName
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

        #try to retrieve the application
        $azureApplication = Get-AzADApplication -DisplayName $ApplicationName -ErrorAction SilentlyContinue

        if ($null -ne $azureApplication)
        {
            #remove the principal
            $azureServicePrincipal = Get-AzADServicePrincipal -ApplicationId $azureApplication.ApplicationId -ErrorAction SilentlyContinue
            if ($null -ne $azureServicePrincipal)
            {
                Trace-Message -Message ("Remove ServicePrincipal for application '{0}'" -f $ApplicationName) -InvocationMethod $MyInvocation.MyCommand
                Remove-AzADServicePrincipal -ObjectId $azureServicePrincipal.Id -Force
            }

            #remove application
            Trace-Message -Message ("Remove application '{0}'" -f $ApplicationName) -InvocationMethod $MyInvocation.MyCommand
            Remove-AzADApplication -ObjectId $azureApplication.ObjectId -Force

            #remove from context
            Remove-MESFServicePrincipalFromContext -ApplicationName $ApplicationName
        }
    }
}

function Sync-MESFAzureVault
{
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [String]
        $Name,

        [Parameter(Mandatory=$true, Position=0)]
        [String]
        $VaultName,

        [Parameter(Mandatory=$true, Position=2)]
        [ValidateSet("ServicePrincipal","User")]
        [String]
        $ObjectType

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
        switch($ObjectType){
            "ServicePrincipal" { $localvaultObject = Get-MESFServicePrincipalFromContext -ApplicationName $Name }
            "User" {$localvaultObject = Get-MESFUserFromContext -Name $Name}
        }

        if ($null -eq $localvaultObject)
        {
            throw "$Name doesn't exist in the localVault"
        }

        Set-AzKeyVaultSecret -VaultName $VaultName -Name $Name -SecretValue  $localvaultObject.Password -ErrorAction Stop
    }
}



<#
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


#>