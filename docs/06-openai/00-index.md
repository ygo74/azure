---
layout: default
title: Open AI
nav_order: 6
has_children: true
---

## Goals

Deploy OpenAI following several methods / best practices described on the Microsoft learn website with several technologies.

## Deployments

az deployment group create -g rg-switzerland-language-spoke  --template-file .\cloud\azure\bicep\openai\main.bicep -p baseName=ygo74-switzerland -p publicNetworkAccess=Enabled

az deployment group create -g rg-switzerland-language-spoke  --template-file .\cloud\azure\bicep\openai\empty.bicep  --mode complete

{"code": "InvalidTemplateDeployment", "message": "The template deployment 'main' is not valid according to the validation procedure. The tracking id is '4ec9532a-910e-4c5e-a11e-82b2b49cff51'. See inner errors for details."}

Inner Errors:
{"code": "FlagMustBeSetForRestore", "message": "An existing resource with ID '/subscriptions/62177529-73f0-4e11-a584-5d3526dc6999/resourceGroups/rg-switzerland-language-spoke/providers/Microsoft.CognitiveServices/accounts/oai-ygo74-switzerland' has been soft-deleted. To restore the resource, you must specify 'restore' to be 'true' in the property. If you don't want to restore existing resource, please purge it first."}


## Sources

- <https://github.com/Azure-Samples/openai-end-to-end-baseline/tree/main>
- <https://learn.microsoft.com/en-us/azure/well-architected/service-guides/azure-openai>
- <https://learn.microsoft.com/en-us/azure/ai-services/recover-purge-resources?tabs=azure-cli#purge-a-deleted-resource>

