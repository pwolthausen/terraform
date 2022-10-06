# Azure Spoke Module

Hub module to create the spoke portion of a hub and spoke architecture. It should be used in tandem with the `mesh` module; the `mesh` module is a dependancy of this one.
The module will create the following resources:

- resource group
- vNET
- subnet(s)
- virtual hub connection back to the hub


### Sample Usage

```hcl
module "app1" {
  source = "../modules/vnet"

  business_unit = "it"
  location      = "Canada Central"
  region_code   = "cac"
  env           = "test"
  app           = "app1"

  address_space = ["192.168.102.0/24"]
  subnets       = { public = ["192.168.102.0/25"], private = ["192.168.102.128/25"] }

  global_tags = {
    costCenter  = "it"
    contact     = "555-876-5309"
}
```

### Inputs

#### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| location | Azure region where resources are being created | string |
| region\_code | Three to four letter code designation for the azure region | string |
| business\_unit | Business unit that owns these resources. Used in names and in tags | string |
| env | Environment of the deployment | string |
| app | Short name of the application stack being deployed | string |
| address\_space | Address space used by the hub virtual network. Must be at least /24 | string |

#### Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| global\_tags | global tags assigned to all resources in the module | map(any) | {} |
| subnets | Mapping of subnets and address prefixes to use with each. Must be a subset of the address_space variable. If unset, a single subnet will be created using the entire available cidr. | map(any) | {} |
| hub_bu | Business unit code used by the hub resource group | string | it |
| hub_env | Environment code used by the hub resource group | string | core |
