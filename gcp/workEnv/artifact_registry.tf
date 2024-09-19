# locals {
#   repositories = [
#     {
#       name          = "docker_hub_proxy"
#       location      = "us"
#       repository_id = "docker-hub-proxy"
#       description   = "Docker Hub public repository"
#       format        = "DOCKER"
#       mode          = "REMOTE_REPOSITORY"
#       labels        = { "access" = "internal" }
#       remote_repository_config = {
#         description = "Docker Hub Proxy"
#         docker_repository = {
#           # public_repository = "DOCKER_HUB" # Only public_repository specified
#         }
#       }
#       virtual_repository_config = null
#       maven_config              = null
#     },
#     {
#       name          = "docker_k8s_gcr_io_proxy"
#       location      = "us"
#       repository_id = "docker-k8s-gcr-io-proxy"
#       description   = "Docker Google K8s public repository"
#       format        = "DOCKER"
#       mode          = "REMOTE_REPOSITORY"
#       labels        = { "access" = "internal" }
#       remote_repository_config = {
#         description = "Google K8s GCR"
#         docker_repository = {
#           custom_repository = { # Only custom_repository specified
#             uri = "https://k8s.gcr.io"
#           }
#         }
#       }
#       virtual_repository_config = null
#       maven_config              = null
#     },
#     {
#       name          = "maven_snapshot"
#       location      = "us"
#       repository_id = "maven-snapshot"
#       description   = "Maven central snapshot repository for CloudMC team"
#       format        = "MAVEN"
#       mode          = "REMOTE_REPOSITORY"
#       labels        = { "access" = "internal" }
#       remote_repository_config = {
#         description = "Maven Snapshot Repo"
#         maven_repository = {
#           # public_repository = "MAVEN_CENTRAL" # Only public_repository specified
#         }
#       }
#       virtual_repository_config = null
#       maven_config = {
#         version_policy            = "SNAPSHOT"
#         allow_snapshot_overwrites = true
#       }
#     },
#     # other repos I will add here once testing is successful
#   ]
# }

# module "artifact_registr" {
#   source  = "GoogleCloudPlatform/artifact-registry/google"
#   version = "~> 0.2"

#   for_each = { for repo in local.repositories : repo.name => repo }

#   project_id    = var.project_id
#   location      = each.value.location
#   repository_id = each.value.repository_id
#   description   = each.value.description
#   format        = each.value.format
#   labels        = each.value.labels
#   mode          = each.value.mode

#   remote_repository_config = each.value.remote_repository_config != null ? each.value.remote_repository_config : null

#   virtual_repository_config = each.value.virtual_repository_config
#   maven_config              = each.value.maven_config
# }

resource "google_artifact_registry_repository" "my-repo" {
  location      = "us-central1"
  repository_id = "example-docker-custom-remote"
  description   = "example remote custom docker repository with credentials"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  remote_repository_config {
    description                 = "custom docker remote with credentials"
    disable_upstream_validation = true
    docker_repository {
      public_repository = "DOCKER_HUB"
      custom_repository {
        uri = "https://registry-1.docker.io"
      }
    }
  }
}
