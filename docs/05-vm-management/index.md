---
layout: default
title: VMs Management
nav_order: 6
has_children: true
---

```powershell

Get-AzVMImagePublisher -Location westeurope | ? {$_.PublisherName -eq 'Redhat'}

Get-AzVMImageOffer -Location westeurope -PublisherName redhat

Get-AzVMImageSku -Location westeurope -PublisherName redhat -Offer RHEL
```