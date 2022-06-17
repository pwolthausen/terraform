<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# 2-networks

This repo is part of a multi-part guide that shows how to configure and deploy
the example.com reference architecture described in
[Google Cloud security foundations guide](https://services.google.com/fh/files/misc/google-cloud-security-foundations-guide.pdf)
(PDF). The following table lists the parts of the guide.

<table>
<tbody>
<tr>
<td><a href="../0-bootstrap">0-bootstrap</td>
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
<td>2-networks (this file)</a></td>
<td>Sets up base and restricted shared VPCs with default DNS, NAT (optional),
Private Service networking, VPC service controls, on-premises Dedicated
Interconnect or VPN, and baseline firewall rules for each environment.</td>
</tr>
<tr>
<td><a href="../3-environments">3-environments</a></td>
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

The purpose of this step is to create shared VPCs and their routes, firewall rules, and subnets used throughout the organization. This step also handles the creation of on prem hybrid connectivity (VPN or interconnect).

## Prerequisites

This step is dependent on the `0-bootstrap` and `1-resource-hierarchy` steps.
The user running this terraform must have the `iam.serviceAccountTokenCreator` role in the devops project to impersonate the terraform service account.
The user must also have the `storage.objectAdmin` role in the devops project to allow the user to upload or edit the remote state.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| org\_id |  The organization id for the associated services. | `string` | `n/a` | yes |
| billing\_account | The ID of the billing account to associate this project with | `string` | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |
| region1 | Primary region where VPCs are deployed. | `string` | n/a | yes |
| region2 | Secondary or fail over region where VPCs are deployed. | `string` | n/a | yes |
| folder\_prefix | Optional - Name prefix to use for folders created. Should be the same in all steps. | `string` | `"fldr"` | no |
| parent\_folder | Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step. | `string` | `""` | no |
| net\_hub\_firewall\_rules | Optional - List of firewall rules to be created for the VPC. There is an explicit deny all ingress and allow all egress as well as a rule to allow IAP and loadbalancer health checks. | `list` | `[]` | no |
| net\_hub\_subnets | Optional - List of subnets to create in the network hub VPC. There should  be at most 1 subnet per required region for the interconnects or VPNs. | `list` | `[]` | no |
| net\_hub\_routes | Optional - List of custom routes to create in the network hub VPC. GCP will still create standard routing in the VPC. See https://github.com/terraform-google-modules/terraform-google-network#route-inputs for syntax. | `list` | `[]` | no |
| hub\_shared\_firewall\_rules | Optional - List of firewall rules to be created for the VPC. There is an explicit deny all ingress and allow all egress as well as a rule to allow IAP and loadbalancer health checks. | `list` | `[]` | no |
| hub\_shared\_subnets | Optional - List of subnets to create in the network hub VPC. There should  be at most 1 subnet per required region for the interconnects or VPNs. | `list` | `[]` | no |
| hub\_shared\_routes | Optional - List of custom routes to create in the network hub VPC. GCP will still create standard routing in the VPC. See https://github.com/terraform-google-modules/terraform-google-network#route-inputs for syntax. | `list` | `[]` | no |
| prod\_vpc\_firewall\_rules | Optional - List of firewall rules to be created for the VPC. There is an explicit deny all ingress and allow all egress as well as a rule to allow IAP and loadbalancer health checks. | `list` | `[]` | no |
| prod\_vpc\_subnets | Optional - List of subnets to create in the network hub VPC. There should  be at most 1 subnet per required region for the interconnects or VPNs. | `list` | `[]` | no |
| prod\_vpc\_routes | Optional - List of custom routes to create in the network hub VPC. GCP will still create standard routing in the VPC. See https://github.com/terraform-google-modules/terraform-google-network#route-inputs for syntax. | `list` | `[]` | no |
| dev\_vpc\_firewall\_rules | Optional - List of firewall rules to be created for the VPC. There is an explicit deny all ingress and allow all egress as well as a rule to allow IAP and loadbalancer health checks. | `list` | `[]` | no |
| dev\_vpc\_subnets | Optional - List of subnets to create in the network hub VPC. There should  be at most 1 subnet per required region for the interconnects or VPNs. | `list` | `[]` | no |
| dev\_vpc\_routes | Optional - List of custom routes to create in the network hub VPC. GCP will still create standard routing in the VPC. See https://github.com/terraform-google-modules/terraform-google-network#route-inputs for syntax. | `list` | `[]` | no |
| qa\_vpc\_firewall\_rules | Optional - List of firewall rules to be created for the VPC. There is an explicit deny all ingress and allow all egress as well as a rule to allow IAP and loadbalancer health checks. | `list` | `[]` | no |
| qa\_vpc\_subnets | Optional - List of subnets to create in the network hub VPC. There should  be at most 1 subnet per required region for the interconnects or VPNs. | `list` | `[]` | no |
| qa\_vpc\_routes | Optional - List of custom routes to create in the network hub VPC. GCP will still create standard routing in the VPC. See https://github.com/terraform-google-modules/terraform-google-network#route-inputs for syntax. | `list` | `[]` | no |
| enable\_interconnect | Optional - Defines if interconnect is being used. Only one of interconnect, partner interconnect, or HA VPN should be enabled. Defaults to false. | `bool` | `false` | no |
| enable\_partner\_interconnect | Optional - Defines if partner interconnect is being used. Only one of interconnect, partner interconnect, or HA VPN should be enabled. Defaults to false. | `bool` | `false` | no |
| enable\_ha\_vpn | Optional - Defines if HA VPN is being used. Only one of interconnect, partner interconnect, or HA VPN should be enabled. Defaults to false. | `bool` | `false` | no |
| vpn\_secret | Optional - Must be defined if using HA VPN or classic VPN. | `string` | `null` | no |
| peer\_ips | Optional - Must be defined if using HA VPN or classic VPN. | `list` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpn\_endpoints | Displays the GCP VPN gateway IPs that the on-prem VPN will need to establish the tunnels. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
