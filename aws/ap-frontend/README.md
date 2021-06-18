```
module aws-frontend {
    source = "https://git.cloudops.com/operations/tf-modules/aws-frontend"
    
    host_zone   = var.host_zone
    name        = var.name
    region      = var.region
    environment = var.environment
    web_server  = var.web_server

}
```

