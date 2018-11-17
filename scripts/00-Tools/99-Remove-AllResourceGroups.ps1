[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param()

#Login-AzureRmAccount


Get-AzureRmResourceGroup | ForEach-Object  {

    $groupName = $_.ResourceGroupName
    Write-Host "Delete resourceGroup $groupName" -ForegroundColor Red
    If ($PSCmdlet.ShouldProcess("Delete $groupName"))
    {
        Remove-AzureRmResourceGroup -Name $groupName -Force -AsJob
    }
}

Get-Job | Wait-Job | Receive-Job