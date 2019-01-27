if ([String]::IsNullOrEmpty($PSScriptRoot)) {
    $rootScriptPath = "D:\devel\github\devops-toolbox\cloud\azure\vault\powershell"
}
else {
    $rootScriptPath = $PSScriptRoot
}    

$ModulePath = "$rootScriptPath\..\..\powershell\modules\MESF_Azure\MESF_Azure\MESF_Azure.psd1" 
Import-Module $ModulePath -force


#Load Vault configuration
& "$rootScriptPath\00-Configuration.ps1"

#Ensure ResourceGroup exist for the Vault
Set-ResourceGroup -ResourceGroupName $ResourceGroupName -Location $Location

#Create the Vault and enable it for deployment
New-AzureRmKeyVault -Name $VaultName -ResourceGroupName $ResourceGroupName -Location $Location `
                    -EnabledForDeployment

#Create a secret value and retrieve it
$secretvalue = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force
Set-AzureKeyVaultSecret -VaultName $VaultName -Name 'SQLPassword' -SecretValue $secretvalue

(get-azurekeyvaultsecret -vaultName $VaultName -name "SQLPassword").SecretValueText


