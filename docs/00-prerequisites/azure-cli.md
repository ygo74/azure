---
layout: default
title: Install azure-cli
parent: Prerequisites
nav_order: 1
has_children: true
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

* [Microsoft Documentation](https://docs.microsoft.com/en-us/cli/azure/)
* [Download page](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

Version as is in 17/11/2018 : 2.0.50

## Install az cli

* For Windows : [Download latest version](https://aka.ms/installazurecliwindows)  

* For Ubuntu  : [Documentation Source](https://docs.microsoft.com/fr-fr/cli/azure/install-azure-cli-apt?view=azure-cli-latest)

    ```bash
    sudo apt-get install apt-transport-https lsb-release software-properties-common -y
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
        sudo tee /etc/apt/sources.list.d/azure-cli.list

    sudo apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
        --keyserver packages.microsoft.com \
        --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF

    sudo apt-get update
    sudo apt-get install azure-cli
    ```

## Install Kubernetes client and link it to az cli

``` bash
az aks install-cli
```

