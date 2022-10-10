data "aws_vpc" "vpc" {
  id = ""
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.vpc.id
}