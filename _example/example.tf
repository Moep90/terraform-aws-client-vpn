##---------------------------------------------------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
##--------------------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-west-1"
}

##---------------------------------------------------------------------------------------------------------------------------
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
##---------------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "1.3.1"

  vpc_enabled     = true
  enable_flow_log = false

  name        = "vpc"
  environment = "example"
  label_order = ["name", "environment"]

  cidr_block = "10.0.0.0/16"
}

##-----------------------------------------------------
## A subnet is a range of IP addresses in your VPC.
##-----------------------------------------------------
module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "1.3.0"

  nat_gateway_enabled = true

  name        = "subnets"
  environment = "example"
  label_order = ["name", "environment"]

  availability_zones = ["eu-west-1a", "eu-west-1b"]
  vpc_id             = module.vpc.vpc_id
  type               = "public-private"
  igw_id             = module.vpc.igw_id
  cidr_block         = module.vpc.vpc_cidr_block
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

##-----------------------------------------------------------------------------
## vpn module call.
##-----------------------------------------------------------------------------
module "vpn" {
  source = "../"

  name                = "test-vpn"
  enabled             = true
  split_tunnel_enable = true
  environment         = "example"
  label_order         = ["name", "environment"]
  cidr_block          = "172.0.0.0/16"
  subnet_ids          = module.subnets.public_subnet_id
  route_cidr          = ["0.0.0.0/0", "0.0.0.0/0"]
  security_group_ids = [""]
  route_subnet_ids    = module.subnets.public_subnet_id
  network_cidr        = ["0.0.0.0/0"]

}