#https://docs.microsoft.com/en-sg/azure/virtual-machines/scripts/virtual-machines-linux-powershell-sample-create-vm-oms?toc=%2Fpowershell%2Fmodule%2Ftoc.json

Function Set-VirtualMachine
{
    [cmdletbinding(DefaultParameterSetName="none")]
    Param( 
        [Parameter(Mandatory=$true)]
        [string]$ResourceGroupName,
    
        [Parameter(Mandatory=$true)]
        [string]$Location,
    
        [Parameter(Mandatory=$true)]
        [Object]$VirtualMachine,

        [Parameter(Mandatory=$false)]
        [pscredential]$Credential

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


        Trace-Message -Message ("Try to retrieve Virtual Machine '{0}' in resourceGroup '{1}'" -f $VirtualMachine.Name, $ResourceGroupName)
        $vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $VirtualMachine.Name -ErrorAction SilentlyContinue

        #Prepare the Network Interface for VMS
        $publicIpName   = [String]::Format("{0}_PublicIp",$VirtualMachine.Name)
        $NICName        = [String]::Format("{0}_Nic", $VirtualMachine.Name)
        $diskName       = [String]::Format("{0}_Disk_OS", $VirtualMachine.Name)
        
        if ($null -eq $Vm)
        {
            #Retrieve Subnet
            $subnet = Get-NetworkSubNet -ResourceGroupName $ResourceGroupName -Location $Location `
                                        -NetworkName $virtualMachine.NetworkName `
                                        -SubnetName $virtualMachine.SubnetName

            #Prepare nic Interface
            $nicSettings = @{
                ResourceGroupName = $ResourceGroupName
                Location          = $Location
                Name              = $NICName
                Subnet            = $subnet
            }

            #Create public IP
            if ($VirtualMachine.EnablePublicIp)
            {
                $PublicIpAddressId = $null
                $publicip = Set-PublicIP -ResourceGroupName $ResourceGroupName -Location $location `
                                -Name $publicIpName `
                                -Alias ("{0}-{1}" -f $ResourceGroupName.ToLower(), $VirtualMachine.Name.ToLower())

                $PublicIpAddressId = $publicip.Id
                Trace-Message -Message ("Public IP '{0}' is identified with id '{1}'" -f $VirtualMachine.PublicIp.Name, $PublicIpAddressId)

                $nicSettings.Add("PublicIpAddressId",$PublicIpAddressId)
            }                

            Trace-Message "Create NIC Interface '$NICName'"
            $nic = Set-NetworkInterface @nicSettings

            #Prepare the VM
            if ($null -eq $Credential)
            {
                $Credential = Get-Credential -Message "Type the name and password of the local administrator account."
            }                

            $VMConfig = New-AzureRmVMConfig -VMName $VirtualMachine.Name -VMSize $VirtualMachine.Size
            switch($VirtualMachine.Type)
            {
                "windows" 
                    { 
                        Set-AzureRmVMOperatingSystem -VM $VMConfig `
                                                    -Windows `
                                                    -ComputerName $VirtualMachine.ComputerName `
                                                    -Credential $Credential `
                                                    -ProvisionVMAgent -EnableAutoUpdate `
                                                    -WinRMHttp
                    }
                "linux"
                    { 
                        Set-AzureRmVMOperatingSystem -VM $VMConfig `
                                                    -Linux `
                                                    -ComputerName $VirtualMachine.ComputerName `
                                                    -Credential $Credential 


                        if ($null -ne $VirtualMachine.SshPublicKey)
                        {
                            Add-AzureRmVMSshPublicKey -VM $VMConfig `
                                                    -KeyData $VirtualMachine.SshPublicKey `
                                                    -Path "/home/$($Credential.UserName.ToLower())/.ssh/authorized_keys"

                            $VMConfig.OSProfile.LinuxConfiguration.DisablePasswordAuthentication = $true
                        }                            
                    }

            }

            #Check if Image exists
            Get-AzureRmVMImage -PublisherName $VirtualMachine.Publisher `
                                -Offer $VirtualMachine.Offer `
                                -Skus $VirtualMachine.skus `
                                -location $Location `
                                -ErrorAction Stop | out-null

            #Add images to the VM
            Set-AzureRmVMSourceImage -VM $VMConfig `
                                    -PublisherName $VirtualMachine.Publisher `
                                    -Offer $VirtualMachine.Offer `
                                    -Skus $VirtualMachine.skus `
                                    -Version latest

            #Add network Interface to the VM
            Add-AzureRmVMNetworkInterface -VM $VMConfig -Id $nic.Id


            Set-AzureRmVMOSDisk -VM $VMConfig -Name $diskName `
                                -StorageAccountType $VirtualMachine.StorageType `
                                -DiskSizeInGB $VirtualMachine.DiskSize `
                                -CreateOption FromImage -Caching ReadWrite

            New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VMConfig
        
        }

        Write-Output $vm
    }
}