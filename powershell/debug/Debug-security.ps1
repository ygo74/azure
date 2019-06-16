# ----------------------------------------------------
# Reggister MESF Credential
# ----------------------------------------------------
Import-Module ..\modules\MESF_Azure\MESF_Azure\MESF_Azure.psd1 -Force
Enable-MESF_AzureDebug
Register-MESFAzureServicePrincipal -Application TestPassword
Register-MESFAzureServicePrincipal -Application TestPassword -ResetPassword

Set-AzKeyVaultSecret -VaultName 1 -Name 2 -SecretValue

# ----------------------------------------------------
# Remove MESF Credential
# ----------------------------------------------------
Import-Module ..\modules\MESF_Azure\MESF_Azure\MESF_Azure.psd1 -Force
Enable-MESF_AzureDebug
Remove-MESFAzureServicePrincipal -ApplicationName TestPassword


$azureApplication = Get-AzADApplication -DisplayName TestPassword
$azureServicePrincipal = Get-AzADServicePrincipal -ApplicationId $azureApplication.ApplicationId


$existingSp = Get-MESFServicePrincipalFromContext -ApplicationName TestPassword
$securepassword = ConvertTo-SecureString -Force -AsPlainText -String $existingSp.Password

$cred = (New-Object PSCredential $existingSp.ApplicationName ,$SecurePassword)

Connect-AzAccount -ServicePrincipal -Credential $cred -Tenant bed92f93-1e03-4d54-b10e-467688282e13

Get-AzADApplication -DisplayName TestPassword |Remove-AzADApplication

Import-Module Az.Resources # Imports the PSADPasswordCredential object
$credentials = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate=Get-Date; EndDate=Get-Date -Year 2024; Password="testpassword.1"}
$credentials

$sp = New-AzAdServicePrincipal -DisplayName TestPassword -PasswordCredential $credentials



$principal = Get-AzADServicePrincipal -DisplayName TestPassword
$retrievedPassword = Get-AzADServicePrincipalCredential -ObjectId $principal.Id
Remove-AzADSpCredential -ObjectId $principal.Id
$newCredential = New-AzADSpCredential -ObjectId $principal.Id -EndDate (Get-Date -Year 2024)

$principal

Get-MESFClearPAssword -Password $newCredential.Secret

$existingConfirmPreference = $ConfirmPreference
$ConfirmPreference = "low"
Remove-AzADServicePrincipal -ObjectId $principal.Id -Force

$ConfirmPreference = $existingConfirmPreference
