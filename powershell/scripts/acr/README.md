# Azure Container Registry : ACR

## Issues

* Registry name : 'RegistryNameCheckRequest.name' must conform to the following pattern: '^[a-zA-Z0-9]*$'

## Deploy with Ansible

``` bash
# Start container
docker run --rm -it -v C:\Users\Administrator\azure_config_ansible.cfg:/root/.azure/credentials -v D:\devel\github\devops-toolbox\cloud\azure:/myapp:rw -w /myapp local/ansible bash

# Container inside
cd acr/ansible/
ansible-playbook create_registries.yml -i /myapp/ansible/ -i localhost
```

## Deploy with Powershell
