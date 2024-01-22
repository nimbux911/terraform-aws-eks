data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_region" "current" {}


data "aws_ami" "this" {
  for_each    = merge(local.custom_node_groups, local.managed_node_groups)
  most_recent = true
  
  filter {
    name   = "image-id"
    values = [each.value.ami_id] 
  }
}
