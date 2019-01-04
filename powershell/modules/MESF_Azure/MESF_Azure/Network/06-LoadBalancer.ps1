Function Set-LoadBalancer
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location,
    
        [Parameter(Mandatory=$true)]
        [String]$Name,

        [Parameter(Mandatory=$true)]
        [String]$Alias,

        [Parameter(Mandatory=$true)]
        [String[]]$VirtualMachineNames

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


        $publicIp = Set-PublicIP -ResourceGroupName $ResourceGroupName -Location $location `
                                -Name  ("{0}-PublicIP" -f $Name) `
                                -Alias $Alias

        $loadBalancerIp = New-AzureRmLoadBalancerFrontendIpConfig -Name ('{0}-FrontEndPool' -f $Name) `
                                -PublicIpAddress $publicIp
                        
        $bepool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name ('{0}-BackEndPool' -f $Name)

        $probe = New-AzureRmLoadBalancerProbeConfig -Name ('{0}-HealthProbe' -f $Name) `
                                -Protocol Http -Port 80 `
                                -RequestPath / -IntervalInSeconds 360 -ProbeCount 5

        $rule = New-AzureRmLoadBalancerRuleConfig -Name HTTP -FrontendIpConfiguration $loadBalancerIp `
                                -BackendAddressPool  $bepool -Probe $probe `
                                -Protocol Tcp -FrontendPort 80 -BackendPort 8080

        $lb = New-AzureRmLoadBalancer -ResourceGroupName $ResourceGroupName -Name ('{0}-LoadBalancer' -f $Name) `
                                    -Location $location -FrontendIpConfiguration $loadBalancerIp `
                                    -BackendAddressPool $bepool `
                                    -Probe $probe -LoadBalancingRule $rule -Sku Basic
        
        foreach($virtualMachine in $VirtualMachineNames)
        {
            $vm = Get-AzureRmVM -Name $virtualMachine -ResourceGroupName $ResourceGroupName                               

            $nicresource = Get-AzureRmResource -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id

            $nicInterface = Get-AzureRmNetworkInterface -Name $nicresource.Name `
                                                        -ResourceGroupName $ResourceGroupName

            $nicInterface.IpConfigurations[0].LoadBalancerBackendAddressPools = $bepool
            Set-AzureRmNetworkInterface -NetworkInterface $nicInterface
        }
        
        Write-Output $lb
    }
}


Function Set-ApplicationGateway
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location,
    
        [Parameter(Mandatory=$true)]
        [String]$Name,

        [Parameter(Mandatory=$true)]
        [String]$VirtualNetworkName,

        [Parameter(Mandatory=$true)]
        [String]$SubnetName,

        [Parameter(Mandatory=$true)]
        [String]$ApplicationName,

        [Parameter(Mandatory=$true)]
        [String]$Alias,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Http","Https")]
        [String]$ListenerProtocol="Http",

        [Parameter(Mandatory=$false)]
        [Int32]$ListenerPort=80,

        [Parameter(Mandatory=$false)]
        [String]$ListenerCertificateFilepath,

        [Parameter(Mandatory=$false)]
        [String]$ListenerCertificatePassword,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Http","Https")]
        [String]$BackendProtocol="Http",

        [Parameter(Mandatory=$false)]
        [Int32]$BackendPort=80,

        [Parameter(Mandatory=$true)]
        [String[]]$BackendVirtualMachineNames

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


        $AliasFQDN = "{0}.{1}.cloudapp.azure.com" -f $Alias, $Location

        $appgw = Get-AzureRmApplicationGateway -Name $Name -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
        
        if ($null -eq $appgw)
        {

            Trace-Message "Application Gateway '$Name' doesn't exist, it will be created"    
            #Create public ip for the gateway
            $gatewayPublicIp = Set-PublicIP -ResourceGroupName $ResourceGroupName -Location $Location `
                                            -Name ("{0}_PublicIP" -f $Name) `
                                            -AllocationMethod Dynamic `
                                            -Alias $Alias

            # Retrieve SubNet for Gateway ip location
            Trace-Message -Message "Retrieve Virtual Network '$VirtualNetworkName' and subnet '$SubnetName'"
            $vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VirtualNetworkName `
                                              -ErrorAction Stop

            $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet `
                                                            -ErrorAction Stop


            # Create IP configurations and frontend port
            Trace-Message -Message "Create frontend gateway configuration"
            $gatewayIpConfigurations = New-AzureRmApplicationGatewayIPConfiguration -Name ("{0}_ConfigIP" -f $Name) `
                                                                                    -Subnet $subnet

            $frontendIPConfiguration = New-AzureRmApplicationGatewayFrontendIPConfig -Name ("{0}_frontendConfigIP" -f $Name) `
                                                                                     -PublicIPAddress $gatewayPublicIp

        }
        else {

            Trace-Message "Application Gateway '$Name' already exists, it will be updated"    
            $frontendIPConfiguration = Get-AzureRmApplicationGatewayFrontendIPConfig -Name ("{0}_frontendConfigIP" -f $Name) `
                                                                                     -ApplicationGateway $appgw


        }

        $frontendPort = Set-ApplicationGatewayFrontendPort -ApplicationName $ApplicationName `
                                                           -Port $ListenerPort `
                                                           -ApplicationGateway $appgw

        $backendAddressPool = Set-ApplicationGatewayBackendAddressPool -ApplicationName $ApplicationName `
                                                                       -BackendVirtualMachineNames $BackendVirtualMachineNames `
                                                                       -ApplicationGateway $appgw

        $probe = Set-ApplicationGatewayProbe -ApplicationName $ApplicationName `
                                             -HostName $AliasFQDN `
                                             -BackendProtocol $BackendProtocol `
                                             -ApplicationGateway $appgw

        $backendHttpSettings = Set-ApplicationGatewayBackendHttpSettings -ApplicationName $ApplicationName `
                                                                         -BackendPort $BackendPort `
                                                                         -BackendProtocol $BackendProtocol `
                                                                         -Probe $probe `
                                                                         -ApplicationGateway $appgw

        # Create the default listener and rule
        Trace-Message -Message "Create Default Listener and default rule"

        $certificate = $null
        if ((![String]::IsNullOrEmpty($ListenerCertificateFilepath)) -and (![String]::IsNullOrEmpty($ListenerCertificatePassword)))
        {
            $certificate = Set-ApplicationGatewayCertificate -ApplicationName $ApplicationName `
                                                             -ListenerCertificateFilepath $ListenerCertificateFilepath `
                                                             -ListenerCertificatePassword $ListenerCertificatePassword `
                                                             -ApplicationGateway $ApplicationGateway
        }

        $applicationlistener = Set-ApplicationGatewayHttpListener -ApplicationName $ApplicationName `
                                                                  -FrontendIPConfiguration $frontendIPConfiguration `
                                                                  -FrontendPort $frontendPort `
                                                                  -HostName $AliasFQDN `
                                                                  -ListenerProtocol $ListenerProtocol `
                                                                  -SslCertificate $certificate `
                                                                  -ApplicationGateway $appgw


        $applicationRule =  Set-ApplicationGatewayRequestRoutingRule -ApplicationName $ApplicationName `
                                                                     -FrontendPort $frontendPort `
                                                                     -HttpListener $applicationlistener `
                                                                     -BackendAddressPool $backendAddressPool `
                                                                     -BackendHttpSettings $backendHttpSettings `
                                                                     -ApplicationGateway $appgw

                                                                         
        if ($appgw -eq $null)
        {
            # Create the application gateway
            Trace-Message -Message "Create the application Gateway $Name"
            $sku = New-AzureRmApplicationGatewaySku -Name "WAF_Medium" -Tier WAF -Capacity 2

            $gatewaySettings = @{
                Name                          = $Name
                ResourceGroupName             = $ResourceGroupName
                Location                      = $Location
                BackendAddressPools           = $backendAddressPool
                BackendHttpSettingsCollection = $backendHttpSettings
                FrontendIpConfigurations      = $frontendIPConfiguration
                GatewayIpConfigurations       = $gatewayIpConfigurations
                FrontendPorts                 = $frontendport
                HttpListeners                 = $applicationlistener
                RequestRoutingRules           = $applicationRule
                Probes                        = $probe
                Sku                           = $sku 
            }
            
            if ($null -ne $certificate)
            {
                $gatewaySettings.Add("SslCertificates", $certificate)
            }

            $appgw = New-AzureRmApplicationGateway @gatewaySettings
        }
        else {
            Trace-Message -Message "Update the application Gateway $Name"
            $appgw = Set-AzureRmApplicationGateway -ApplicationGateway $appgw
        }

        Write-Output $appgw                                            
    }
}    
