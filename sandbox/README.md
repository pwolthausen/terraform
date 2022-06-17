# Compass Group Infrastructure

This set of repos is a a multi-part guide that shows how to configure and deploy
the example.com reference architecture described in
[Google Cloud security foundations guide](https://services.google.com/fh/files/misc/google-cloud-security-foundations-guide.pdf)
(PDF). The following table lists the parts of the guide.

<table>
<tbody>
<tr>
<td><a href="./0-bootstrap">0-bootstrap</td>
<td>Bootstraps a Google Cloud organization, creating all the required resources
and permissions to start using the Cloud Foundation Toolkit (CFT).</td>
</tr>
<tr>
<td><a href="./1-resource_hierarchy">1-resource_hierarchy</a></td>
<td>Sets up top level shared folders, monitoring and networking projects, and
organization-level logging, and sets baseline security settings through
organizational policy.</td>
</tr>
<tr>
<td><a href="./2-networks">2-networks</a></td>
<td>Sets up base and restricted shared VPCs with default DNS, NAT (optional),
Private Service networking, VPC service controls, on-premises Dedicated
Interconnect or VPN, and baseline firewall rules for each environment.</td>
</tr>
<tr>
<td><a href="./3-environments">3-environments</a></td>
<td>Set up a folder structure, projects, and application infrastructure pipeline for applications,
 which are connected as service projects to the shared VPC created in the previous stage.</td>
</tr>
<tr>
<td><a href="./4-infrastructure">4-infrastructure</a></td>
<td>This section is broken into separate projects/workloads. There is a terraform workspace for the org shared resources, and each of the dev/qa/prod environments are separated into specific projects/workloads.</td>
</tr>
</tbody>
</table>

## Prerequisites

To run the commands described in this document, you need to have the following
installed:

- The [Google Cloud SDK](https://cloud.google.com/sdk/install) version 319.0.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 1.0.3 or later.

**Note:** Make sure that you use the same version of Terraform throughout this series. Otherwise, you might experience Terraform state snapshot lock errors.

Also make sure that you've done the following:

1. Set up a Google Cloud
   [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization).
1. Set up a Google Cloud
   [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account).
1. Created Cloud Identity or Google Workspace (formerly G Suite) groups for
   organization and billing admins.
1. Added the user who will use Terraform to the `group_org_admins` group.
   They must be in this group, or they won't have
   `roles/resourcemanager.projectCreator` access.
1. For the user who will run the procedures in this document, granted the
   following roles:
   -  The `roles/resourcemanager.organizationAdmin` role on the Google
      Cloud organization.
   -  The `roles/billing.admin` role on the billing account.
   -  The `roles/resourcemanager.folderCreator` role.
   -  The `roles/resourcemanager.projectCreator` role.
   -  The `roles/iam.serviceAccountTokenCreator` role (at the org level or in the devops project).
      This role allows the user to impersonate the terraform service account once the bootstrap has been completed.

Once the bootstrap step is completed, any user that needs to run terraform will need the
`roles/iam.serviceAccountTokenCreator` role to impersonate the terraform service account.
For more information about the permissions that are required, and the resources
that are created, see the organization bootstrap module
[documentation.](https://github.com/terraform-google-modules/terraform-google-bootstrap)

## Running Terraform locally

If you want to execute Terraform locally, you need to add your Cloud
Storage bucket to the `backend.tf` files. You can update all of these files with
the following steps:

1. Run the following command in the root of the repo:
   ```
   for i in `find -name 'backend.tf'`; do sed -i 's/<bucket-name>/GCS_BUCKET_NAME/' $i; done
   ```
   where `GCS_BUCKET_NAME` is the name of your bucket from the steps you ran
   earlier.
