Environment with a scaling front end server using MIG to handle auto-healing and auto-scaling
The MIG is exposed using a Global Load Balancer and is backed by cloudSQL DB

###Note
Make sure the APIs for the various resources are enabled before running terraform apply (cloudsql, compute, resource manager)

The terraform service account must include the `Network Admin` role or it will be unable to create the private service connection
The SQL database may take a while to create. The default timeout for the SQL resource is 20 minutes. If you lower this, you may get an error from terraform, though the resource may still be created
