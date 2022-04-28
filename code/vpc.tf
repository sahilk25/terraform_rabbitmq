module "mq_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.env_name}-my-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.avz_list.zone_ids
#   one subnet per avz
  private_subnets= [for i in range(length(data.aws_availability_zones.avz_list.zone_ids)): "10.0.${i+1}.0/24"]
  public_subnets  = [for i in range(length(data.aws_availability_zones.avz_list.zone_ids)): "10.0.${i+100}.0/24"]

  enable_dhcp_options = true 
  enable_dns_hostnames = true

  enable_nat_gateway = true
  enable_vpn_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false


  tags = {
    "terraform-env" = "${var.env_name}"
  }
}