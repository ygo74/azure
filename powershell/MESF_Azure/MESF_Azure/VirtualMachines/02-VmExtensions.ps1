$Global:AzureRmVMExtensionsUbuntu=@{
    Ansible = "apt-get update && apt-get --assume-yes install software-properties-common && apt-add-repository ppa:ansible/ansible && apt-get update && apt-get --assume-yes install ansible"
    PythonPackager = "apt-get install python-pip --assume-yes"
    AnsibleWindowsRequirement = "pip install 'pywinrm>=0.3.0';rm -rf /usr/lib/python2.7/dist-packages/OpenSSL/;pip install pyOpenSSL"
    JavaJre = "apt install default-jre -y"
    Jenkins = "wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add - && sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list' && apt-get update && apt-get install jenkins -y"
}

$Global:AzureRmVMExtensionsWindows=@{
    WinrmActivation = 'winrm set winrm/config/client/auth @{Basic=\"true\"} | winrm set winrm/config/service/auth @{Basic=\"true\"} | winrm set winrm/config/service @{AllowUnencrypted=\"true\"}'
}


Function Set-VirtualMachineExtension
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location,
    
        [Parameter(Mandatory=$true)]
        [Object]$VirtualMachine

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
        if ($null -eq $VirtualMachine.Extensions)
        {
            return $null        
        }
        switch($virtualMachine.Type)
        {
            "linux"
            {
                Set-VirtualMachineLinuxExtension -ResourceGroupName $ResourceGroupName -Location $Location `
                   -VirtualMachine $VirtualMachine 
            }
            "windows"
            {
                Set-VirtualMachineWindowsExtension -ResourceGroupName $ResourceGroupName -Location $Location `
                   -VirtualMachine $VirtualMachine 
            }
        }            
    }
}            

Function Set-VirtualMachineLinuxExtension
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location,
    
        [Parameter(Mandatory=$true)]
        [Object]$VirtualMachine

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
        $existingExtension = Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName `
                                -VMName $virtualMachine.Name -Name "Custom-$($virtualMachine.Name)"
        
        if ($null -ne $existingExtension)
        {
            return $existingExtension
        }                              

        $PublicSettings = '{"commandToExecute": "' + ($virtualMachine.Extensions.Values -join ';') + '"}'

        Trace-Message $PublicSettings

        Set-AzureRmVMExtension -ExtensionName "Custom-$($virtualMachine.Name)" -ResourceGroupName $ResourceGroupName `
           -VMName $virtualMachine.Name -Publisher "Microsoft.Azure.Extensions" `
           -ExtensionType "CustomScript" -TypeHandlerVersion 2.0 `
           -SettingString $PublicSettings -Location $location

    }
}            

Function Set-VirtualMachineWindowsExtension
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location,
    
        [Parameter(Mandatory=$true)]
        [Object]$VirtualMachine

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
        foreach($extensionKey in $virtualMachine.Extensions.Keys)
        {
            $existingExtension = Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName `
                                    -VMName $virtualMachine.Name -Name $extensionKey
            
            if ($null -eq $existingExtension)
            {
                $PublicSettings = '{"commandToExecute": "' + $virtualMachine.Extensions[$extensionKey]  + '"}'
                Trace-Message $PublicSettings

                Set-AzureRmVMExtension -ExtensionName $extensionKey -ResourceGroupName $ResourceGroupName `
                   -VMName $virtualMachine.Name -Publisher "Microsoft.Compute" `
                   -ExtensionType "CustomScriptExtension" -TypeHandlerVersion 1.9 `
                   -SettingString $PublicSettings -Location $location                               
            }
        }                                                

    }
}            
