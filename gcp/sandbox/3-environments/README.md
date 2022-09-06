<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# 3-environments

This repo is part of a multi-part guide that shows how to configure and deploy
the example.com reference architecture described in
[Google Cloud security foundations guide](https://services.google.com/fh/files/misc/google-cloud-security-foundations-guide.pdf)
(PDF). The following table lists the parts of the guide.

<table>
<tbody>
<tr>
<td><a href="../0-bootstrap">0-bootstrap</a></td>
<td>Bootstraps a Google Cloud organization, creating all the required resources
and permissions to start using the Cloud Foundation Toolkit (CFT).</td>
</tr>
<tr>
<td><a href="../1-resource_hierarchy">1-resource_hierarchy</a></td>
<td>Sets up top level shared folders, monitoring and networking projects, and
organization-level logging, and sets baseline security settings through
organizational policy.</td>
</tr>
<tr>
<td><a href="../2-networks">2-networks</a></td>
<td>Sets up base and restricted shared VPCs with default DNS, NAT (optional),
Private Service networking, VPC service controls, on-premises Dedicated
Interconnect or VPN, and baseline firewall rules for each environment.</td>
</tr>
<tr>
<td>3-environments (this file)</td>
<td>Set up a folder structure, projects, and application infrastructure pipeline for applications,
 which are connected as service projects to the shared VPC created in the previous stage.</td>
</tr>
<tr>
<td><a href="../4-infrastructure">4-infrastructure</a></td>
<td>This section is broken into separate projects/workloads. There is a terraform workspace for the org shared resources, and each of the dev/qa/prod environments are separated into specific projects/workloads.</td>
</tr>
</tbody>
</table>

## Purpose

The purpose of this step is to create the environments where infrastructure will be built to deploy or support application stacks. The `shared` environment is for support services used by all environments (such as Active Directory Domain Controllers). These resources are accessible from any other environment.
The prod/qa/dev environments are isolated from each other. It is recommended to create separate projects within each environment for different application stacks.

## Prerequisites

This step is dependent on the `0-bootstrap`, `1-resource-hierarchy`, and `2-networks` steps.
The user running this terraform must have the `iam.serviceAccountTokenCreator` role in the devops project to impersonate the terraform service account.
The user must also have the `storage.objectAdmin` role in the devops project to allow the user to upload or edit the remote state.

## Adding new projects

To ensure consistency in project creation, to add new projects to an environment, duplicate the `main.tf` file and replace the current application name (3dxp) with the new application name.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| org\_id |  The organization id for the associated services. | `string` | `n/a` | yes |
| billing\_account | The ID of the billing account to associate this project with | `string` | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |
| folder\_prefix | Optional - Name prefix to use for folders created. Should be the same in all steps. | `string` | `"fldr"` | no |
| parent\_folder | Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step. | `string` | `""` | no |
| prj\_PROJECTNAME\_iam | This variable will be repeated with a different `PROJECTNAME` in each. This is used to assign IAM permissions to groups at the project level. This does not replace inherited permissions from the organization or folder levels. This should be used when providing access only to specific projects within the organization. This is especially useful when working with small teams or third parties. | map(object({roles = list(string)})) | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| PROJECTNAME\_project\_id | This output will be repeated multiple times with different `PROJECTNAME` in each. This outputs the project IDs created in this step. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
