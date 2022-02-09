---
layout: default
title: Install Powershell Az
parent: Prerequisites
nav_order: 2
has_children: false
---

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

## Resources

* [Microsoft Documentation](https://docs.microsoft.com/en-us/powershell/azure/?view=azps-7.2.0)
* [Persistent context](https://docs.microsoft.com/fr-fr/powershell/azure/context-persistence?view=azps-7.2.0)

## Remove AzureRM powershell module

* AzureRM and Az modules installed for PowerShell 5.1 on Windows at the same time is not supported
* Ensure that all powershell windows (vscode included) are closed before uninstall

```powershell
# Uninstall the old azureRM powershell
Uninstall-AzureRm
```

## Install Az Module

```powershell
# Install the new module
Install-Module -Name Az -AllowClobber
Get-InstalledModule -Name Az -AllVersions | select Name,Version
Get-InstalledModule | ? {$_.Name -like 'Az*'} | select Name,Version

Install-Module -Name powershell-yaml
```

## Check usage

```powershell
# Connect to Azure with a browser sign in token
Connect-AzAccount
Get-AzSubscription
```

## Configuration

### Persistent login

* Informations are stored in __$env:USERPROFILE\.Azure__ or __$HOME/.Azure__

```powershell
# Enable context persistence
Enable-AzContextAutosave
# Connect to Azure with a browser sign in token
Connect-AzAccount

# To Disable
# Disable-AzContextAutosave
```
