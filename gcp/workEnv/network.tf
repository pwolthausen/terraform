##Create network and subnets
module "core_network" {
  source  = "terraform-google-modules/network/google"
  version = "9.0.0"

  project_id                             = var.project_id
  network_name                           = "vpc-pw-core"
  shared_vpc_host                        = "false"
  delete_default_internet_gateway_routes = "false"

  firewall_rules = [
    {
      name      = "fw-pw-core-allow-internal"
      direction = "INGRESS"
      priority  = 100
      ranges    = ["192.168.0.0/19", "10.0.0.0/20"]
      allow = [
        {
          protocol = "all"
          ports    = []
        }
      ]
    },
    {
      name        = "fw-pw-core-allow-ssh"
      direction   = "INGRESS"
      priority    = 100
      ranges      = ["${var.my_ip}/32"]
      target_tags = ["bastion"]
      allow = [
        {
          protocol = "TCP"
          ports    = ["22"]
        }
      ]
    }
  ]

  subnets = [
    {
      subnet_name           = "dublin"
      subnet_ip             = "192.168.0.0/23"
      subnet_region         = "northamerica-northeast1"
      subnet_private_access = true
    },
    {
      subnet_name           = "cork"
      subnet_ip             = "192.168.2.0/24"
      subnet_region         = "us-east1"
      subnet_private_access = true
    },
    # {
    #   subnet_name           = "galway"
    #   subnet_ip             = "192.168.3.0/24"
    #   subnet_region         = "us-central1"
    #   subnet_private_access = true
    # },
    # {
    #   subnet_name           = "limrick"
    #   subnet_ip             = "192.168.4.0/24"
    #   subnet_region         = "us-west1"
    #   subnet_private_access = true
    # },
    # {
    #   subnet_name           = "sligo"
    #   subnet_ip             = "192.168.5.0/24"
    #   subnet_region         = "europe-west2"
    #   subnet_private_access = true
    # },
  ]

  secondary_ranges = {
    dublin = [
      {
        range_name    = "pod-cidr"
        ip_cidr_range = "10.0.0.0/21"
      },
      {
        range_name    = "service-cidr-0"
        ip_cidr_range = "10.0.8.0/23"
      },
      {
        range_name    = "service-cidr-1"
        ip_cidr_range = "10.0.10.0/23"
      },
      {
        range_name    = "service-cidr-2"
        ip_cidr_range = "10.0.12.0/23"
      },
      {
        range_name    = "service-cidr-3"
        ip_cidr_range = "10.0.14.0/23"
      },
    ],
    cork = [
      {
        range_name    = "pod-cidr"
        ip_cidr_range = "10.1.0.0/21"
      },
      {
        range_name    = "service-cidr-0"
        ip_cidr_range = "10.1.8.0/23"
      },
      {
        range_name    = "service-cidr-1"
        ip_cidr_range = "10.1.10.0/23"
      },
      {
        range_name    = "service-cidr-2"
        ip_cidr_range = "10.1.12.0/23"
      },
      {
        range_name    = "service-cidr-3"
        ip_cidr_range = "10.1.14.0/23"
      },
    ]
  }
}

##Create network and subnets
# module "alternate_network" {
#   source  = "terraform-google-modules/network/google"
#   version = "5.2.0"

#   project_id                             = var.project_id
#   network_name                           = "vpc-pw-alternate"
#   shared_vpc_host                        = "false"
#   delete_default_internet_gateway_routes = "true"

#   firewall_rules = [
#     {
#       name      = "fw-pw-alt-allow-internal"
#       direction = "INGRESS"
#       priority  = 100
#       ranges    = ["192.168.32.0/19", "10.0.16.0/20"]
#       allow = [
#         {
#           protocol = "all"
#           ports    = []
#         }
#       ]
#     }
#   ]

#   subnets = [
#     {
#       subnet_name           = "belfast"
#       subnet_ip             = "192.168.32.0/23"
#       subnet_region         = "northamerica-northeast1"
#       subnet_private_access = true
#     },
#   ]

#   # secondary_ranges = {
#   #   belfast = [
#   #     {
#   #       range_name    = "pod-cidr"
#   #       ip_cidr_range = "10.0.16.0/21"
#   #     },
#   #     {
#   #       range_name    = "service-cidr-0"
#   #       ip_cidr_range = "10.0.24.0/23"
#   #     },
#   #     {
#   #       range_name    = "service-cidr-1"
#   #       ip_cidr_range = "10.0.26.0/23"
#   #     },
#   #     {
#   #       range_name    = "service-cidr-2"
#   #       ip_cidr_range = "10.0.28.0/23"
#   #     },
#   #     {
#   #       range_name    = "service-cidr-3"
#   #       ip_cidr_range = "10.0.30.0/23"
#   #     },
#   #   ]
#   # }
# }

# resource "google_compute_router" "router" {
#   name    = "pw-router"
#   region  = module.core_network.subnets_regions[0]
#   network = module.core_network.network_id

#   bgp {
#     asn = 64514
#   }
# }

# resource "google_compute_router_nat" "nat" {
#   name                               = "pw-router-nat"
#   router                             = google_compute_router.router.name
#   region                             = google_compute_router.router.region
#   nat_ip_allocate_option             = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

#   log_config {
#     enable = true
#     filter = "ERRORS_ONLY"
#   }
# }

# module "network_network-peering" {
#   source  = "terraform-google-modules/network/google//modules/network-peering"
#   version = "6.0.1"

#   local_network = module.core_network.network_self_link
#   peer_network  = module.alternate_network.network_self_link
# }

# module "private_service_access" {
#   source  = "GoogleCloudPlatform/sql-db/google//modules/private_service_access"
#   version = "20.0.0"

#   project_id    = var.project_id
#   vpc_network   = module.core_network.network_name
#   address       = "192.168.56.0"
#   prefix_length = "21"

#   depends_on = [
#     module.core_network,
#   ]
# }
