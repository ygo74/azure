# ----------------------------------------------------
# Register MESF Credential
# ----------------------------------------------------
Import-Module MESF_Azure -Force
Enable-MESF_AzureDebug
Register-MESFAzureServicePrincipal -Application TestPassword
Register-MESFAzureServicePrincipal -Application TestPassword -ResetPassword

# ----------------------------------------------------
# Synchronize Azure vault with local information
# ----------------------------------------------------
Import-Module MESF_Azure -Force
Enable-MESF_AzureDebug
Sync-MESFAzureVault -VaultName mesfVault -Name TestPassword -ObjectType ServicePrincipal

# ----------------------------------------------------
# Get Service Principal from Local Context
# ----------------------------------------------------
Import-Module MESF_Azure -Force
Enable-MESF_AzureDebug
$existingSp = Get-MESFServicePrincipalFromContext -ApplicationName TestPassword

# ----------------------------------------------------
# Get clear password
# ----------------------------------------------------
Import-Module MESF_Azure -Force
Enable-MESF_AzureDebug
$existingSp = Get-MESFServicePrincipalFromContext -ApplicationName TestPassword
Get-MESFClearPAssword -Password $existingSp.Password

# ----------------------------------------------------
# Use service principal to connect to Azure
# ----------------------------------------------------
Import-Module MESF_Azure -Force
Enable-MESF_AzureDebug
$existingSp = Get-MESFServicePrincipalFromContext -ApplicationName TestPassword
$cred = (New-Object PSCredential $azureApplication.ApplicationId ,$existingSp.Password)
$tenantId = (Get-AzSubscription).TenantId

Connect-AzAccount -ServicePrincipal -Credential $cred -Tenant $tenantId

# ----------------------------------------------------
# Assign role
# ----------------------------------------------------
Import-Module MESF_Azure -Force
Enable-MESF_AzureDebug
$azureApplication = Get-AzADApplication -DisplayName TestPassword
New-AzRoleAssignment -ApplicationId $azureApplication.ApplicationId -RoleDefinitionName "Reader"

# ----------------------------------------------------
# Remove MESF Credential
# ----------------------------------------------------
Import-Module MESF_Azure -Force
Enable-MESF_AzureDebug
Remove-MESFAzureServicePrincipal -ApplicationName TestPassword
