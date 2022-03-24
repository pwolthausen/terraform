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
