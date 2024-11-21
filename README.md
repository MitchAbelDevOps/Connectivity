# azure-connectivity
This repo contains Terraform code for deploying networking/connectivity infrastructure to Azure.

## Workflows:
This repo contains a workflow per resource which will target the Terraform under the folder for that resource.

There is also a workflow to deploy all resources in a given resource group with the name starting with rg-. This name denotes which resource group it will deploy. The targeted Terraform in this case will be the main.tf in the resource group Infrastructure folder which calls all the individual resource Terraform files as modules.