param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true)]
    [string]$Location,

    [Parameter(Mandatory=$true)]
    [Object]$VirtualMachine,

    [Parameter(Mandatory=$true)]
    [Object]$Subnet

)

#Prepare the Network Interface for VMS
$publicIpName   = [String]::Format("{0}_publicIp_{1}", $ResourceGroupName , $VirtualMachine.Name)
$NICName        = [String]::Format("{0}_nic_{1}", $ResourceGroupName , $VirtualMachine.Name)
$diskName       = [String]::Format("{0}_disk_{1}", $ResourceGroupName , $VirtualMachine.Name)

$publicIp = Get-AzureRmPublicIpAddress -Name $publicIpName `
                                       -ResourceGroupName $ResourceGroupName

if ($publicIp -eq $null)
{
    $publicIp = New-AzureRmPublicIpAddress -Name $publicIpName `
                                           -ResourceGroupName $ResourceGroupName `
                                           -Location $Location `
                                           -AllocationMethod Dynamic
}

$nic = Get-AzureRmNetworkInterface -Name $NICName `
                                   -ResourceGroupName $ResourceGroupName

if ($nic -eq $null)
{
    $nic = New-AzureRmNetworkInterface -Name $NICName `
                                       -ResourceGroupName $ResourceGroupName `
                                       -Location $Location `
                                       -SubnetId $Subnet.Id `
                                       -PublicIpAddressId $publicIp.Id
}

#Prepare the VM
$cred = Get-Credential -Message "Type the name and password of the local administrator account."

$VMConfig = New-AzureRmVMConfig -VMName $VirtualMachine.Name -VMSize $VirtualMachine.Size
switch($VirtualMachine.Type)
{
    "windows" 
        { 
            Set-AzureRmVMOperatingSystem -VM $VMConfig `
                                         -Windows `
                                         -ComputerName $VirtualMachine.ComputerName `
                                         -Credential $cred `
                                         -ProvisionVMAgent -EnableAutoUpdate 
        }
    "linux"
        { 
            Set-AzureRmVMOperatingSystem -VM $VMConfig `
                                         -Linux `
                                         -ComputerName $VirtualMachine.ComputerName `
                                         -Credential $cred 
        }

}

#Check if Image exists
$images = Get-AzureRmVMImage -PublisherName $VirtualMachine.Publisher `
                             -Offer $VirtualMachine.Offer `
                             -Skus $VirtualMachine.skus `
                             -location $Location `
                             -ErrorAction Stop

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

$vm = New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VMConfig

Write-Output $vm