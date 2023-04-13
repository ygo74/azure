---
layout: default
title: Deploy root resources
nav_order: 3
has_children: true
---

## Goals

Keep the control of resources usages, used identity, and network design.

The following resources are qualified as root objects and can be deployed only by the **root automation service account** :

* Resources groups
* Virtual Networks
* Storages
* User Managed identity
* Services principals
* User Managed identity and service principals permissions

Each new application / services deployment has to request their needs.

## Deployment architecture



## Deployment status

Azure devops pipeline : [![Build Status](https://dev.azure.com/ygo74/iac/_apis/build/status%2FDeploy%20subscription%20root%20objects?branchName=master)](https://dev.azure.com/ygo74/iac/_build/latest?definitionId=33&branchName=master){:target="_blank"}
