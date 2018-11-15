Function Set-ApplicationGatewayFrontendPort
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ApplicationName,

        [Parameter(Mandatory=$false)]
        [Int32]$Port=80,
    
        [Parameter(Mandatory=$false)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGateway]
        $ApplicationGateway
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
        $frontendPortName = "{0}_{1}_FrontendPort" -f $ApplicationName, $Port
        if ($null -eq $ApplicationGateway)
        {
            #Application Gateway doesn't exist, we have to create a new frontendPort
            Trace-Message "Create new Frontend port '$frontendPortName' for new gateway"
            return New-AzureRmApplicationGatewayFrontendPort -Name $frontendPortName `
                                                      -Port $Port
        }

        #Application Gateway already exist, we have to add it the frontendPort if it doesn't exist
        Trace-Message "Retrieve Frontend port '$frontendPortName'"
        $frontendPort = Get-AzureRmApplicationGatewayFrontendPort -ApplicationGateway $ApplicationGateway `
                                                                  -Name $frontendPortName `
                                                                  -ErrorAction SilentlyContinue

        if ($null -eq $frontendPort)
        {
            #Application Gateway already exist, we have to add it the frontendPort
            Trace-Message "Add new Frontend port '$frontendPortName' for existing gateway"
            $ApplicationGateway = Add-AzureRmApplicationGatewayFrontendPort -ApplicationGateway $ApplicationGateway `
                                                                      -Name $frontendPortName `
                                                                      -Port $Port

            $frontendPort = Get-AzureRmApplicationGatewayFrontendPort -ApplicationGateway $ApplicationGateway `
                                                                      -Name $frontendPortName
        }

        Write-Output $frontendPort
    }
}        

Function Set-ApplicationGatewayBackendAddressPool
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ApplicationName,

        [Parameter(Mandatory=$true)]
        [string[]]$BackendVirtualMachineNames,
    
        [Parameter(Mandatory=$false)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGateway]
        $ApplicationGateway
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
        $backendIpAdresses = @()
        foreach($VmName in $BackendVirtualMachineNames)
        {
            Trace-Message "Retrieve private IP for VM '$VmName'"
            $vm = Get-AzureRmVM -Name $VmName -ResourceGroupName $resourceGroupName -ErrorAction Stop
            $nicAzureResource = Get-AzureRmResource -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id
            $nicInterface = Get-AzureRmNetworkInterface -Name $nicAzureResource.Name -ResourceGroupName $ResourceGroupName

            $backendIpAdresses += $nicInterface.IpConfigurations[0].PrivateIpAddress
        }


        $backendAdressPoolName = "{0}_Pool" -f $ApplicationName
        if ($null -eq $ApplicationGateway)
        {
            #Application Gateway doesn't exist, we have to create a new BackendAdressPool
            Trace-Message "Create new BackendAddressPool '$backendAdressPoolName' for new gateway"
            return New-AzureRmApplicationGatewayBackendAddressPool -Name $backendAdressPoolName `
                                                                                 -BackendIPAddresses $backendIpAdresses    
        }

        #retrieve BackendAdressPool for existing gateway
        $backendAdressPool = Get-AzureRmApplicationGatewayBackendAddressPool -ApplicationGateway $ApplicationGateway `
                                                                             -Name $backendAdressPoolName `
                                                                             -ErrorAction SilentlyContinue

        if ($null -eq $backendAdressPool)
        {
            #Application Gateway already exist, we have to add it the BackendAdressPool
            Trace-Message "Add new BackendAddressPool '$backendAdressPoolName' for existing gateway"
            $ApplicationGateway = Add-AzureRmApplicationGatewayBackendAddressPool -ApplicationGateway $ApplicationGateway `
                                                                                  -Name $backendAdressPoolName `
                                                                                  -BackendIPAddresses $backendIpAdresses  

            $backendAdressPool = Get-AzureRmApplicationGatewayBackendAddressPool -ApplicationGateway $ApplicationGateway `
                                                                                  -Name $backendAdressPoolName                                                                    
        }

        Write-Output $backendAdressPool
    }
}        


Function Set-ApplicationGatewayBackendHttpSettings
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ApplicationName,

        [Parameter(Mandatory=$false)]
        [Int32]$BackendPort=80,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Http","Https")]
        [String]$BackendProtocol="Http",

        [Parameter(Mandatory=$false)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGatewayProbe]$Probe,

        [Parameter(Mandatory=$false)]        
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGateway]
        $ApplicationGateway
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

        $backendHttpSettingsName = "{0}_PoolSettings" -f $ApplicationName
        #Common parameters
        $Settings = @{
            Name                = $backendHttpSettingsName
            Port                = $BackendPort
            Protocol            = $BackendProtocol
            CookieBasedAffinity = "Enabled"
            RequestTimeout      = 120
        }

        #Add probe if exist
        if ($null -ne $Probe)
        {
            $Settings.Add("Probe", $Probe)
        }

        #Create or Add BackendHttpSettings
        if ($null -eq $ApplicationGateway)
        {
            #Application Gateway doesn't exist, we have to create a new BackendHttpSettings
            Trace-Message "Create new BackendHttpSettings '$backendHttpSettingsName' for new gateway"
            return New-AzureRmApplicationGatewayBackendHttpSettings @Settings 
        }

        #retrieve backendHttpSettings for existing gateway
        $backendHttpSettings = Get-AzureRmApplicationGatewayBackendHttpSettings -ApplicationGateway $ApplicationGateway `
                                                                                -Name $backendHttpSettingsName `
                                                                                -ErrorAction SilentlyContinue

        if ($null -eq $backendHttpSettings)
        {
            #Application Gateway already exist, we have to add it the BackendHttpSettings
            Trace-Message "Add new BackendHttpSettings '$backendHttpSettingsName' for existing gateway"
            $ApplicationGateway = Add-AzureRmApplicationGatewayBackendHttpSettings -ApplicationGateway $ApplicationGateway `
                                                                                   @Settings

            $backendHttpSettings = Get-AzureRmApplicationGatewayBackendHttpSettings -ApplicationGateway $ApplicationGateway `
                                                                                    -Name $backendHttpSettingsName                                                                                                                                                           
        }                                                                                

        Write-Output $backendHttpSettings
    }
}    


Function Set-ApplicationGatewayProbe
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ApplicationName,

        [Parameter(Mandatory=$false)]
        [String]$HostName,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Http","Https")]
        [String]$BackendProtocol="Http",

        [Parameter(Mandatory=$false)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGateway]
        $ApplicationGateway
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

        $probeName = "{0}_Probe" -f $ApplicationName
        #Common parameters
        $Settings = @{
            Name                = $probeName
            HostName            = $HostName
            Protocol            = $BackendProtocol
            Path                = "/"
            Interval            = 10
            Timeout             = 5
            UnhealthyThreshold  = 3
            Match               = (New-AzureRmApplicationGatewayProbeHealthResponseMatch -StatusCode "403")
        }


        #Create or Add GatewayProbeConfig
        if ($null -eq $ApplicationGateway)
        {
            #Application Gateway doesn't exist, we have to create a new gatewayProbeConfig
            Trace-Message "Create new Probe '$probeName' for new gateway"
            return New-AzureRmApplicationGatewayProbeConfig @Settings
        }

        #retrieve probe for an existing gateway
        $gatewayProbeConfig = Get-AzureRmApplicationGatewayProbeConfig -ApplicationGateway $ApplicationGateway `
                                                                       -Name $probeName `
                                                                       -ErrorAction SilentlyContinue

        if ($null -eq $gatewayProbeConfig) 
        {
            #Application Gateway already exist, we have to add it the gatewayProbeConfig
            Trace-Message "Add new Probe '$probeName' for existing gateway"
            $ApplicationGateway = Add-AzureRmApplicationGatewayProbeConfig -ApplicationGateway $ApplicationGateway `
                                                                            @Settings

            $gatewayProbeConfig = Get-AzureRmApplicationGatewayProbeConfig -ApplicationGateway $ApplicationGateway `
                                                                           -Name $probeName                                                                                                                                                           
        }                                                                                

        Write-Output $gatewayProbeConfig
    }
}    

Function Set-ApplicationGatewayHttpListener
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ApplicationName,

        [Parameter(Mandatory=$true)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGatewayFrontendIPConfiguration]
        $FrontendIPConfiguration,

        [Parameter(Mandatory=$true)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGatewayFrontendPort]
        $FrontendPort,

        [Parameter(Mandatory=$false)]
        [String]$HostName,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Http","Https")]
        [String]$ListenerProtocol="Http",

        [Parameter(Mandatory=$false)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGatewaySslCertificate]
        $SslCertificate,
        
        [Parameter(Mandatory=$false)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGateway]
        $ApplicationGateway
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

        $ListenerName = "{0}_{1}_Listener" -f $ApplicationName, $FrontendPort.Port
        #Common parameters
        $Settings = @{
            Name                    = $ListenerName
            Protocol                = $ListenerProtocol
            FrontendIPConfiguration = $FrontendIPConfiguration
            FrontendPort            = $FrontendPort
        }

        #Add hostName
        if (![String]::IsNullOrEmpty($HostName))
        {
            $Settings.Add("HostName", $HostName)
        }

        #Add Certificate
        if ($null -ne $SslCertificate)
        {
            $Settings.Add("SslCertificate", $SslCertificate)                                                             
        }


        #Create or Add HttpListener
        if ($null -eq $ApplicationGateway)
        {
            #Application Gateway doesn't exist, we have to create a new HttpListener
            Trace-Message "Create new HttpListener '$ListenerName' for new gateway"
            return New-AzureRmApplicationGatewayHttpListener @Settings
        }

        #retrieve HttpListener for existing Gateway
        $httpListener = Get-AzureRmApplicationGatewayHttpListener -ApplicationGateway $ApplicationGateway `
                                                                  -Name $ListenerName `
                                                                  -ErrorAction SilentlyContinue

        if ($null -eq $httpListener) 
        {
            #Application Gateway already exist, we have to add it the HttpListener
            Trace-Message "Add HttpListener '$ListenerName' for existing gateway"
            $ApplicationGateway = Add-AzureRmApplicationGatewayHttpListener -ApplicationGateway $ApplicationGateway `
                                                                            @Settings

            $httpListener = Get-AzureRmApplicationGatewayHttpListener -ApplicationGateway $ApplicationGateway `
                                                                      -Name $ListenerName                                                                                                                                                           
        }                                                                                

        Write-Output $httpListener
    }
}    

Function Set-ApplicationGatewayRequestRoutingRule
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ApplicationName,

        [Parameter(Mandatory=$true)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGatewayFrontendPort]
        $FrontendPort,

        [Parameter(Mandatory=$true)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGatewayHttpListener]$HttpListener,

        [Parameter(Mandatory=$true)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGatewayBackendHttpSettings]$BackendHttpSettings,

        [Parameter(Mandatory=$true)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGatewayBackendAddressPool]$BackendAddressPool,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Http","Https")]
        [String]$ListenerProtocol="Http",
        
        [Parameter(Mandatory=$false)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGateway]
        $ApplicationGateway
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

        $ruleName = "{0}_{1}_Rule" -f $ApplicationName, $FrontendPort.Port
        #Common parameters
        $Settings = @{
            Name                = $ruleName
            RuleType            = "Basic"
            HttpListener        = $HttpListener
            BackendAddressPool  = $BackendAddressPool
            BackendHttpSettings = $BackendHttpSettings
        }

        #Create or Add RequestRoutingRule
        if ($null -eq $ApplicationGateway)
        {
            #Application Gateway doesn't exist, we have to create a new RequestRoutingRule
            Trace-Message "Create requestRoutingRule '$ruleName' for new gateway"
            return New-AzureRmApplicationGatewayRequestRoutingRule @Settings            
        }

        $requestRoutingRule = Get-AzureRmApplicationGatewayRequestRoutingRule -ApplicationGateway $ApplicationGateway `
                                                                              -Name $ruleName `
                                                                              -ErrorAction SilentlyContinue


        if ($null -eq $requestRoutingRule) 
        {
            #Application Gateway already exist, we have to add it the RequestRoutingRule
            Trace-Message "Add requestRoutingRule '$ruleName' for existing gateway"
            $ApplicationGateway = Add-AzureRmApplicationGatewayRequestRoutingRule -ApplicationGateway $ApplicationGateway `
                                                                            @Settings

            $requestRoutingRule = Get-AzureRmApplicationGatewayRequestRoutingRule -ApplicationGateway $ApplicationGateway `
                                                                      -Name $ruleName                                                                                                                                                           
        }                                                                                

        Write-Output $requestRoutingRule
    }
}    

Function Set-ApplicationGatewayCertificate
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ApplicationName,

        [Parameter(Mandatory=$true)]
        [String]$ListenerCertificateFilepath,

        [Parameter(Mandatory=$true)]
        [String]$ListenerCertificatePassword,
        
        [Parameter(Mandatory=$false)]
        [Microsoft.Azure.Commands.Network.Models.PSApplicationGateway]
        $ApplicationGateway
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

        if (-not(Test-Path -Path $ListenerCertificateFilepath -PathType Leaf))
        {
            Throw New-Object System.Exception "Missing certifcate file at '$ListenerCertificateFilepath' to create a SSL Terminaison"
        }

        $securePassword = ConvertTo-SecureString  $ListenerCertificatePassword -AsPlainText -Force 
        $CertificateName = "{0}_Certificate" -f $ApplicationName

        #Common parameters
        $Settings = @{
            Name                    = $CertificateName
            CertificateFile         = $ListenerCertificateFilepath
            Password                = $securePassword
        }

        
        #Create or Add Certificate
        if ($null -eq $ApplicationGateway)
        {
            #Application Gateway doesn't exist, we have to create a new RequestRoutingRule
            Trace-Message "Create Certificate '$CertificateName' for new gateway"
            return New-AzureRmApplicationGatewaySslCertificate @Settings            
        }

        $certificate = Get-AzureRmApplicationGatewaySslCertificate -ApplicationGateway $ApplicationGateway `
                                                                   -Name $CertificateName `
                                                                   -ErrorAction SilentlyContinue

        if ($null -eq $certificate) 
        {
            #Application Gateway already exist, we have to add it the RequestRoutingRule
            Trace-Message "Add Certificate '$CertificateName' for existing gateway"
            $ApplicationGateway = Add-AzureRmApplicationGatewaySslCertificate -ApplicationGateway $ApplicationGateway `
                                                                              @Settings

            $certificate = Get-AzureRmApplicationGatewaySslCertificate -ApplicationGateway $ApplicationGateway `
                                                                       -Name $CertificateName `
                                                                       -ErrorAction Stop                                                                                                                                                           
        }                                                                                

        Write-Output $certificate
    }                                                             
}            
