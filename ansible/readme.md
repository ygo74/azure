# Ansible for Azure

## Documentation
* Microsoft : [Documentation relative à Ansible sur Azure](https://docs.microsoft.com/fr-fr/azure/ansible/)  
* Ansible : [Documentation relative à Ansible sur Azure](https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html)  

## Install ansible
python3 -m venv my_venv
source my_venv/bin/activate
pip install wheel
pip install --upgrade pip
pip install 'ansible'

pip install  -r https://raw.githubusercontent.com/ansible-collections/azure/dev/requirements-azure.txt


ansible-galaxy collection install azure.azcollection
ansible-galaxy collection install community.general

## Prerequisites

* Update Workspace Settings : 
"ansible.customOptions": "-i cloud/azure/ansible"

* Update $HOME/.vscode/ansible-credentials.yml :

azure:
  AZURE_CLIENT_ID:       ''
  AZURE_SECRET:          ''
  AZURE_SUBSCRIPTION_ID: ''
  AZURE_TENANT:          ''


vi ~/.azure/credentials
[default]
subscription_id=<your-subscription_id>
client_id=<security-principal-appid>
secret=<security-principal-password>
tenant=<security-principal-tenant>

Get-AzSubscription
$x = Get-MESFServicePrincipalFromContext -ApplicationName Ansible-Automation
Get-MESFClearPAssword -Password $x.Password
