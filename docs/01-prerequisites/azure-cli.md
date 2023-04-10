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

1. Install Kubernetes client

    ``` bash
    # Install kubectl client
    az aks install-cli

    # Please add "C:\Users\Administrator\.azure-kubelogin" to your search PATH so the `kubelogin.exe` can be found. 2 options: 
    #     1. Run "set PATH=%PATH%;C:\Users\Administrator\.azure-kubelogin" or "$env:path += 'C:\Users\Administrator\.azure-kubelogin'" for PowerShell. This is good for the current command session.
    #     2. Update system PATH environment variable by following "Control Panel->System->Advanced->Environment Variables", and re-open the command window. You only need to do it once
    ```

    this command installs:

    * kubectl client into "$env:USERPROFILE\.azure-kubectl"
    * kubelogin client into "$env:USERPROFILE\.azure-kubelogin"

2. Configure Kubernetes client path

    ``` powershell
    # Current role
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity

    # default scope is for user path
    $scope = "User"
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
      # if user is admin, we can update the machine path
      $scope = "Machine"
    }  

    $updateKubeLoginPath = $true
    $updateKubeCtlPath = $true

    # Check from Machine Path
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($currentPath.Contains("\.azure-kubelogin")) {$updateKubeLoginPath = $false}
    if ($currentPath.Contains("\.azure-kubectl")) {$updateKubeCtlPath = $false}

    # Check from User Path
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath.Contains("\.azure-kubelogin")) {$updateKubeLoginPath = $false}
    if ($currentPath.Contains("\.azure-kubectl")) {$updateKubeCtlPath = $false}

    if ($updateKubeLoginPath)
    {
      write-host "Update user path to kubelogin" -foreGroundColor Green
      # current session Modify current value with your folder
      $env:Path += ";$(join-path -Path $env:USERPROFILE -ChildPath ".azure-kubelogin")"

      # Persistent Modify current value with your folder
      [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$(join-path -Path $env:USERPROFILE -ChildPath ".azure-kubelogin")", "User")
      
    }

    if ($updateKubeCtlPath)
    {
      write-host "Update user path to kubectl" -foreGroundColor Green
      # current session Modify current value with your folder
      $env:Path += ";$(join-path -Path $env:USERPROFILE -ChildPath ".azure-kubectl")"

      # Persistent Modify current value with your folder
      [Environment]::SetEnvironmentVariable("Path", $currentPath + ";$(join-path -Path $env:USERPROFILE -ChildPath ".azure-kubectl")", "User")
      
    }

    ```
