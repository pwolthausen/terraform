# Azure Hub Module

Hub module to create the hub portion of a hub and spoke architecture.
The module will create the following resources:

- vWAN
- Secured virtual hub (includes firewall)
- Firewall policy
- Virtual Network gateway
- VPN sites
- VPN gateway connections

The module supports BGP if desired but will use static routes if no BGP parameters are defined.

### Sample Usage

```hcl
```

### Inputs

#### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| location | Azure region where resources are being created | string |
| region\_code | Three to four letter code designation for the azure region | string |
| business\_unit | Business unit that owns these resources. Used in names and in tags | string |
| address\_space | Address space used by the hub virtual network. Must be at least /24 | string |

#### Optional Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| env | Environment of the deployment | string | core |
| global\_tags | global tags assigned to all resources in the module | map(any) | {} |
| bgp\_settings | Block to enable BGP and define the BGP endpoints on the gateway. If undefined, BGP will be disabled. | <pre>map(object({<br>  link0 = string<br>  link1 = string<br>}))</pre> | {} |
| vpn\_connections | Definition of the different VPN connections. Each block within contains the definition of a single VPN site with connections | <pre>map(object({<br> shared_key = string<br> address_cidrs = optional(list(string))<br>  vpn\_links = map(object({<br>   peer\_ip = string<br>   bgp = optional(map(object({<br>     asn = string<br>      bgp\_peer\_ip = string<br>    })))<br>  }))<br>}))</pre> | {} |
| application\_rule\_collection | each block defines an application rule to add to the firewall policy | <pre>map(object({<br>  priority = number<br> action = string<br> rules = map(object({<br>    source\_addresses = optional(list(any))<br>   source\_ip\_groups = optional(list(any))<br>    destination_urls = optional(list(any))<br>   destination\_fqdns = optional(list(any))<br>   destination\_fqdn\_tags = optional(list(any))<br>    terminate\_tls = optional(bool)<br>   web\_categories = <br>    protocols = map(any)<br> }))<br>})) | {} |
