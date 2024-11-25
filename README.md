# azure-connectivity
This repo contains Terraform code for deploying networking/connectivity infrastructure to Azure.

## Workflows:
This repo contains a workflow per resource which will target the Terraform under the folder for that resource.

There is also a workflow to called .infra-rg-{resourceGroupName}-tewheke-orchestration-workflow.yaml. This worfklow calls other workflows in the repo in the pre-determined order required to deploy the resource group correctly.