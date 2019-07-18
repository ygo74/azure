# Azure Vault

https://docs.microsoft.com/fr-fr/azure/key-vault/key-vault-get-started

## Create Vault
```powershell
#Create the Vault and enable it for deployment
New-AzKeyVault -Name $inventoryVars.vault.name `
               -ResourceGroupName $azResourceGroup.ResourceGroupName `
               -Location $azResourceGroup.Location `
               -EnabledForDeployment
```

## Set an retrieve password
```powershell
#Create a secret value and retrieve it
$secretvalue = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force
Set-AzKeyVaultSecret  -VaultName $VaultName -Name 'SQLPassword' -SecretValue $secretvalue

(Get-AzKeyVaultSecret  -vaultName $VaultName -name "SQLPassword").SecretValueText
```

## Known Exceptions

### Missing Provider

__Error Message__ : L’abonnement n’est pas inscrit pour utiliser l’espace de noms « Microsoft.KeyVault »

__Resolution__ : Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.KeyVault"
