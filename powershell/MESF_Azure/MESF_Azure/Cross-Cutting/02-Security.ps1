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

Function Get-UserCredential
{
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


