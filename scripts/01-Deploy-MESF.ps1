$rootScriptPath = "D:\devel\Azure\git\microsvc\azure\scripts"

& "$rootScriptPath\..\configuration\01-Load-Common-Values.ps1"
$VirtualNetworks = & "$rootScriptPath\..\configuration\02-Load-Networks.ps1"
$VirtualMachines = & "$rootScriptPath\..\configuration\03-Load-VirtualMachines.ps1"


..\virtual-machines\01-Create-VirtualMachine.ps1 -ResourceGroupName $ResourceGroupName -Location $Location


