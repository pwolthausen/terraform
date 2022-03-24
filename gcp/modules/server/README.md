# Module gcp server

### Purpose

Builds out a server with

### Example

```
module "gcp-server" {
    source = ""

    project_id     = ""
    serverName     = "test-server"
    region         = "us-central1"
    zone           = "us-central1-c"
    image          = ""
    machine_type   = "e2-medium"
    root_disk_size = "100"
    root_disk_type = "pd-ssd"
    addDisk        = {
      0 = {
        size = ""
        type = ""
      },
      1 = {
        size = ""
        type = ""
      }
    }
    snapshotPolicy = ""
    network        = ""
    subnet         = ""
    internal_ip    = ""
    external_ip    = true
    tags           = []
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | Project ID where the resources will be created | `string` | n/a | yes |
| serverName | Name of the VM instance and the disk(s) | `string` | n/a | yes |
| machine\_type |  | `string` | `"e2-medium"` | no |
| region | Default region to create resources where applicable. | `string` | `"us-central1"` | no |
| zone | Zone within the region where the resources will be created | `string` | `"us-central1-c"` | no |
| image |  | `string` | `"projects/debian-cloud/global/images/debian-11"` | no |
| network | Network ID for the VM NIC. This module only supports a single NIC | `string` | null | no |
| subnet | Subnet name within the chosen Network | `string` | null | no |
| internal\_ip | Optional - An IP address to assign to the primary NIC, chosen from within the CIDR of the selected subnet. Must not currently be in use. | `string` | null | no |
| external\_ip | Optional - If set to true, an external IP will be assigned to the VM. | `bool` | `false` | no |
| tags | Optional - A list of network tags assigned to the VM. | `list(string)` | `[]` | no |
| labels | Optional - A map of labels to assign to the VM and disk resources. | `map(any)` | `{}` | no |
| metadata | Optional - Key value pairs added to the instance, used for startup scripts or other metadata needed to be attached to the instance | map(string) | {} | no |
| root\_disk\_size | Optional - The size of the boot disk in GB. Defaults to 125. | `string` | `"100"` | no |
| root\_disk\_type | Optional - The type of disk to use for the boot disk. Defaults to pd-standard. | `string` | `"pd-standard"` | no |
| addDisk | Optional - Array of objects, defines additional disks attached to the instance. | `map(object({size = string, type = string}))` | {} | no |
| allow_stopping_for_update | Optional - Allows the VM to be stopped for updates and maintenance by Google. Defaults to true. | `bool` | `true` | no |
| snapshotPolicy | Optional - Sets the snapshot schedule name (google_compute_resource_policy) to use for the VM's disk(s). If unset, no snapshot schedule will be assigned to the disks | `string` | null | no |
| hostname | Optional - Sets the hostname of the VM. This must be a fully qualified domain name. Defaults to null  | `string` | null | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_name | Name of the instance.  |
| instance_selflink | Selflink of the VM. |
| instance_private_ip | private IP of the instance. |
| instance_public_ip | Public IP of the instance. |
