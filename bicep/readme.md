https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts

https://github.com/Azure/ALZ-Bicep/blob/main/infra-as-code/bicep/modules/hubNetworking/hubNetworking.bicep




- <https://github.com/mspnp/samples/blob/main/solutions/azure-hub-spoke/bicep/main.bicep>



## structure azure landing zones :

- https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/

- https://github.com/Azure/ALZ-Bicep

- https://github.com/nicolgit/hub-and-spoke-playground/tree/main

### structure bicep :

- https://rkeytech.io/blogs/2023/01/structuring-maintainable-bicep-code/
- https://devops.stackexchange.com/questions/12803/best-practices-for-app-and-infrastructure-code-repositories

limitations :
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/best-practices#template-limits

The parameter file also should be less than 4 MB. On top of these, the following limitations also need to be considered.

256 parameters
256 variables
800 resources (including copy count)
64 output values
10 unique locations per subscription/tenant/management group scope
24,576 characters in a template expression



## Open policy agent : https://www.openpolicyagent.org/docs/latest/
