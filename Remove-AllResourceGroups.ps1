[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param()

#Login-AzureRmAccount


Get-AzureRmResourceGroup | ForEach-Object  {

    $groupName = $_.ResourceGroupName
    Write-Host "Delete resourceGroup $groupName" -ForegroundColor Red
    If ($PSCmdlet.ShouldProcess("Delete $groupName"))
    {
        Remove-AzureRmResourceGroup -Name $groupName -Force
    }
}

<#
Get-AzureRmResourceGroup | Select-Object -First 1 | ForEach-Object  {

    $groupName = $_.ResourceGroupName
    Write-Host "Delete resourceGroup $groupName" -ForegroundColor Red
    If ($PSCmdlet.ShouldProcess("Delete $groupName"))
    {
        Start-Job -ScriptBlock {param($Name) Remove-AzureRmResourceGroup -Name $Name -Force } -ArgumentList $groupName
    }

    #Wait to avoid rejected request 
    #Start-Sleep 30

}

Get-Job | Wait-Job | Receive-Job

#>