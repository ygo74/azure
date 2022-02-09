# Ansible for Azure

## Documentation
* Microsoft : [Documentation relative à Ansible sur Azure](https://docs.microsoft.com/fr-fr/azure/ansible/)  
* Ansible : [Documentation relative à Ansible sur Azure](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html)  

## Prerequisites

### Ansible Installation
* Installation documentation : [Automation / Ansible ](https://github.com/ygo74/ansible/blob/master/README.md)

### Azure collection for ansible
Azure collection :  [Github source](https://github.com/ansible-collections/azure)


```bash
pip install  -r https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements-azure.txt
ansible-galaxy collection install azure.azcollection
```


### Vscode configuration
* Update Workspace Settings : 
"ansible.customOptions": "-i cloud/azure/ansible"

* Update $HOME/.vscode/ansible-credentials.yml :

azure:
  AZURE_CLIENT_ID:       ''
  AZURE_SECRET:          ''
  AZURE_SUBSCRIPTION_ID: ''
  AZURE_TENANT:          ''


### Azure development environment configuration
vi ~/.azure/credentials
[default]
subscription_id=<your-subscription_id>
client_id=<security-principal-appid>
secret=<security-principal-password>
tenant=<security-principal-tenant>

Get-AzSubscription
$x = Get-MESFServicePrincipalFromContext -ApplicationName Ansible-Automation
Get-MESFClearPAssword -Password $x.Password
