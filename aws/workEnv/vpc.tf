# variable "environment" {
#   type    = string
#   default = "pw-sandbox"
# }

# resource "aws_vpc" "vpc" {
#   cidr_block = "192.168.128.0/20"
#   tags = merge(local.tags, {
#     Name = "pw-sandbox-vpc"
#   })
# }

# ######################
# ### Public subnets ###
# ######################
# resource "aws_internet_gateway" "public" {
#   vpc_id = aws_vpc.vpc.id

#   tags = local.tags
# }
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.public.id
#   }
#   tags = local.tags
#   lifecycle {
#     ignore_changes = [route]
#   }
# }
# resource "aws_subnet" "public_subnets" {
#   count                   = length(local.availability_zones)
#   availability_zone       = local.availability_zones[count.index]
#   cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index + (2 * length(local.availability_zones)))
#   map_public_ip_on_launch = true
#   vpc_id                  = aws_vpc.vpc.id
#   tags = merge(local.tags, {
#     Usage = "Public"
#     Zone  = local.availability_zones[count.index]
#     Name  = "pw-public-${local.availability_zones[count.index]}"
#   })
# }
# resource "aws_route_table_association" "internet" {
#   count          = length(local.availability_zones)
#   subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
#   route_table_id = aws_route_table.public.id
# }

# #######################
# ### Private subnets ###
# #######################
# resource "aws_eip" "nat" {
#   domain = "vpc"
#   tags = merge(local.tags, {
#     Name = "${var.environment}-nat-ip"
#   })
# }
# resource "aws_nat_gateway" "private" {
#   subnet_id     = aws_subnet.public_subnets[0].id
#   allocation_id = aws_eip.nat.id
# }
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.private.id
#   }
#   tags = merge(local.tags, {
#     Name = "rtt-private"
#   })
#   lifecycle {
#     ignore_changes = [route]
#   }
# }
# resource "aws_subnet" "private_subnets" {
#   count                   = length(local.availability_zones)
#   availability_zone       = local.availability_zones[count.index]
#   cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index)
#   map_public_ip_on_launch = false
#   vpc_id                  = aws_vpc.vpc.id
#   tags = merge(local.tags, {
#     Usage = "Private"
#     Zone  = local.availability_zones[count.index]
#     Name  = "pw-private-${local.availability_zones[count.index]}"
#   })
# }
# resource "aws_route_table_association" "web_route_table_association" {
#   count          = length(local.availability_zones)
#   subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
#   route_table_id = aws_route_table.private.id
# }
