# aws-cloudfront

build cloudfront, route 53 and ACM to act as a frontend for web applications and static content


```
module cloudfront {
  source         = "./modules/cloudfront"
  aws_profile    = var.aws_profile
  environment    = var.environment
  host_zone      = var.host_zone
  domains        = var.domains
  vanity_domains = var.vanity_domains
  origin         = module.service.origin
}
```

## variables

#### aws_profile

This is the name of the profile being used for your AWS CLI profile. This must be specified for this module since a new provider is created in this module to fetch resources in us-east-1 no matter where the deployment is being run.

#### environment

Should be either production or staging.

#### region

AWS region, must be a valid region.

#### host_zone

This must be an existing global AWS hosted zone used by clients.

#### domains

This is a list of domains that will be hosted on the web servers for the linked deployment.

#### vanity_domains
