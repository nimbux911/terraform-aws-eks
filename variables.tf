variable "environment" {}
variable "cluster_name" {}
variable "cluster_version" {}
variable "vpc_id" {}
variable "subnets_ids" {}
variable "instance_type" {}
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "eks_worker_ami_id" {}
variable "target_group_arns" {
    default = []
}

variable "health_check_type" {
    default = "EC2"
}


variable "asg_tags" {
  default = []
}

variable "eks_tags" {
    default = {}
}

variable "eks_api_private" {
    default = false
}

variable "add_configmap_roles" {
    default = ""
}