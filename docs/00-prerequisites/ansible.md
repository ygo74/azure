---
layout: default
title: Install Ansible
parent: Prerequisites
nav_order: 3
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

## Ansible installation and configuration

Standard Installation : Got to automation/ansible/README.md
Azure prerequisites : TODO

## Configuration

__VSCode__ : "C:\Users\Administrator\.vscode\ansible-credentials.yml"

## Docker file

```DockerFile
FROM python:3.9-alpine

RUN apk update && apk upgrade \
    && apk add --no-cache --virtual .pipeline-deps readline linux-pam \
    && apk add bash sudo shadow \
    && apk add bash py3-pip git \
    && apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python3-dev make \
    && pip --no-cache-dir install -U pip \
    && pip install -r https://raw.githubusercontent.com/ansible-collections/azure/v1.14.0/requirements-azure.txt \
    && pip install ansible \
    && ansible-galaxy collection install azure.azcollection \
    && apk del .pipeline-deps \
    && apk del --purge build

```