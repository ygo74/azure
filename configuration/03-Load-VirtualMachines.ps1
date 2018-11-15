$vmDatas=@(
        New-Object -TypeName PsObject -Property @{
            Name="Vm1"
            ComputerName="srv1"
            Size="Standard_DS1_v2"
            Type="Windows"
            Publisher="MicrosoftWindowsServer"
            Offer="WindowsServer"
            skus="2012-R2-Datacenter-smalldisk"
            StorageType="StandardLRS"
            DiskName="Vm1_Disk"
            DiskSize=40
        }
        New-Object -TypeName PsObject -Property @{
            Name="Vm2"
            ComputerName="srv2"
            Size="Standard_DS1_v2"
            Type="Linux"
            Publisher="Canonical"
            Offer="UbuntuServer"
            skus="16.04-LTS"
            StorageType="Premium_LRS"
            DiskName="Vm2_Disk"
            DiskSize=40
        }
        New-Object -TypeName PsObject -Property @{
            Name="Vm3"
            ComputerName="srv3"
            Size="Standard_DS1_v2"
            Type="Windows"
            Publisher="MicrosoftVisualStudio"
            Offer="VisualStudio"
            skus="VS-2015-Ent-VSU3-AzureSDK-29-WS2012R2"
            DiskName="Vm1_Disk"
            DiskSize=128
        }
        New-Object -TypeName PsObject -Property @{
            Name="Vm4"
            ComputerName="srv4"
            Type="Windows"
            Size="Standard_DS1_v2"
            Publisher="MicrosoftWindowsServer"
            Offer="WindowsServer"
            skus="2012-R2-Datacenter-smalldisk"
            StorageType="StandardLRS"
            DiskName="Vm1_Disk"
            DiskSize=40
        }
      )

Write-Output $vmDatas