Function New-KeyFile
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [ValidateScript({Test-Path $_ -PathType Container})]
        [String]
        $Path,

        [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [String]
        $KeyfileName,

        [switch]
        $Force
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
        $Key = New-Object Byte[] 32   # You can use 16, 24, or 32 for AES
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)

        $KeyFilePath = Join-Path -Path $Path -ChildPath $KeyfileName

        if (-not(Test-Path -Path $KeyFilePath -PathType Leaf) -or $Force)
        {
            if ($Force)
            {
                Trace-Message "Force keyfile creation"
                Write-Warning "If existing password have been created, you have to recreate and regiostered passwords"
            }

            $Key | out-file $KeyFilePath
            Trace-Message "Key File '$KeyFilePath' has been created"
        }
    }
}

Function Set-MESFServicePrincipalToContext
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [PsObject]
        $ServicePrincipal
    )
    Process
    {
        Assert-MESFAzureContext
        if ($script:MESF_AzureContext.ServicePrincipals.ContainsKey($ServicePrincipal.ApplicationName))
        {
            Trace-Message -Message ("Update service principal for application '{0}'" -f $ServicePrincipal.ApplicationName)  -InvocationMethod $MyInvocation.MyCommand
            $script:MESF_AzureContext.ServicePrincipals[$ServicePrincipal.ApplicationName] = $ServicePrincipal
        }
        else
        {
            Trace-Message -Message ("Add new service principal for application '{0}'" -f $ServicePrincipal.ApplicationName)  -InvocationMethod $MyInvocation.MyCommand
            $script:MESF_AzureContext.ServicePrincipals.Add($ServicePrincipal.ApplicationName, $ServicePrincipal)
        }

        Save-MESFAzureContext
    }
}

Function Set-MESFUserToContext
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [PsObject]
        $User
    )
    Process
    {
        Assert-MESFAzureContext
        if ($script:MESF_AzureContext.Users.ContainsKey($User.UserPrincipalName))
        {
            Trace-Message -Message ("Update user '{0}'" -f $User.UserPrincipalName)  -InvocationMethod $MyInvocation.MyCommand
            $script:MESF_AzureContext.Users[$User.UserPrincipalName] = $User
        }
        else
        {
            Trace-Message -Message ("Add new user '{0}'" -f $User.UserPrincipalName) -InvocationMethod $MyInvocation.MyCommand
            $script:MESF_AzureContext.Users.Add($User.UserPrincipalName, $User)
        }

        Save-MESFAzureContext
    }
}

Function Get-MESFServicePrincipalFromContext
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [String]
        $ApplicationName
    )
    Process
    {
        Assert-MESFAzureContext
        if ($script:MESF_AzureContext.ServicePrincipals.ContainsKey($ApplicationName))
        {
            Trace-Message -Message ("Get service principal for application '{0}'" -f $ApplicationName) -InvocationMethod $MyInvocation.MyCommand
            write-output $script:MESF_AzureContext.ServicePrincipals[$ApplicationName]
        }
        else
        {
            Trace-Message -Message ("Service principal for application '{0}' doesn't exist" -f $ApplicationName) -InvocationMethod $MyInvocation.MyCommand
            return $null
        }
    }
}

Function Get-MESFUserFromContext
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [String]
        $Name
    )
    Process
    {
        Assert-MESFAzureContext
        if ($script:MESF_AzureContext.Users.ContainsKey($Name))
        {
            Trace-Message -Message ("Get User '{0}'" -f $Name)
            write-output $script:MESF_AzureContext.Users[$Name]
        }
        else
        {
            Trace-Message -Message ("User '{0}' doesn't exist" -f $Name) -InvocationMethod $MyInvocation.MyCommand
            return $null
        }
    }
}

Function Remove-MESFServicePrincipalFromContext
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
        [String]
        $ApplicationName
    )
    Process
    {
        Assert-MESFAzureContext
        if ($script:MESF_AzureContext.ServicePrincipals.ContainsKey($ApplicationName))
        {
            Trace-Message -Message ("Remove service principal for application '{0}'" -f $ApplicationName)  -InvocationMethod $MyInvocation.MyCommand
            $script:MESF_AzureContext.ServicePrincipals.Remove($ApplicationName)

            Save-MESFAzureContext
        }
    }
}
