---
layout: default
title: Prerequisites
parent: AKS
nav_order: 1
has_children: false
---

## Install kubelogin

Installation is done thanks to azure-cli into your profile directory.

```powershell
az aks install-cli

$env:path += '{0}\.azure-kubelogin' -f $env:USERPROFILE

```
