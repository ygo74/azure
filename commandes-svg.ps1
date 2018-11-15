Add-Type -Assembly System.Web
$password = [System.Web.Security.Membership]::GeneratePassword(16,3)
$securePassword = ConvertTo-SecureString -Force -AsPlainText -String $password
New-AzureRmADServicePrincipal -ApplicationId $mesf_Application.ApplicationId -Password $securePassword


New-AzureRmADServicePrincipal

$password = "Y4Lw-^qbK!+KlD0:"


$cred = Get-Credential -UserName $mesf_Application.ApplicationId 

$currentContext = Get-AzureRmContext

$cred = new-object -typename System.Management.Automation.PSCredential `
     -argumentlist $mesf_Application.ApplicationId, $SecurePassword

Connect-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $currentContext.Tenant

Set-AzureRMContext -Subscription "MESF Powershell" -Name "MESF_Powershell"


Connect-AzureRmAccount
$mesf_Application = Get-AzureRmADApplication -IdentifierUri http://MESF_Powershell
$password = "Y4Lw-^qbK!+KlD0:"
$securePassword = ConvertTo-SecureString -Force -AsPlainText -String $password
$cred = new-object -typename System.Management.Automation.PSCredential `
     -argumentlist $mesf_Application.ApplicationId, $SecurePassword

$currentContext = Get-AzureRmContext

$mesf_Application_sp = Get-AzureRmADServicePrincipal -ServicePrincipalName "http://MESF_Powershell"
New-AzureRmRoleAssignment -ResourceGroupName MESF -ObjectId $mesf_Application_sp.Id -RoleDefinitionName Contributor


Get-AzureRmRoleAssignment -ResourceGroupName MESF -ObjectId $mesf_Application_sp.Id


Connect-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $currentContext.Tenant




Enable-AzureRmContextAutosave


$x = Get-Content -Path "C:\Users\Administrator\.mesf_azure\.Vault"
