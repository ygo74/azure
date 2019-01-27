# Azure Vault

https://docs.microsoft.com/fr-fr/azure/key-vault/key-vault-get-started


## Known Exceptions

### Missing Provider

Error Message : L’abonnement n’est pas inscrit pour utiliser l’espace de noms « Microsoft.KeyVault »  

Resolution : Register-AzureRmResourceProvider -ProviderNamespace "Microsoft.KeyVault"  
