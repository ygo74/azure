#!/bin/bash

if [[ -z $ANSIBLE_VAULT_FILES ]]
then
   read -sp 'Type the Vault Password for Ansible Files:' ANSIBLE_VAULT_FILES
   export ANSIBLE_VAULT_FILES
   echo $ANSIBLE_VAULT_FILES
fi

echo $ANSIBLE_VAULT_FILES

