# module "foundation" {
#   source = "../ap-regional-foundation"

#   region             = "ca-central-1"
#   availability_zones = []
#   environment        = "pw-test"
#   access_ips         = ["142.115.192.104"]
# }

data "aws_ami" "windows-2019" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "platform"
    values = ["windows"]
  }
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }
}
