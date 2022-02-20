$queryLocation = "westeurope"

Get-AzVMImagePublisher -Location $queryLocation
Get-AzVMExtensionImageType -Location $queryLocation -PublisherName "Canonical"
Get-AzVMExtensionImage -Location $queryLocation -PublisherName "Canonical"

Get-AzVMImagePublisher -Location $queryLocation | `
Get-AzVMExtensionImageType | `
Get-AzVMExtensionImage | Select-Object Type, Version