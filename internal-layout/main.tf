/**
* This module creates a internal only layout with the following resources
* inside a network:
*
* 1. An internal subnet for each availability zone in a region.
*
* Usage:
*
* ```hcl
* module "network_layout" {
*   source              = "github.com/scipian/quoins//internal-layout"
*   vpc_id              = "vpc-*****"
*   availability_zones  = "us-west-2a,us-west-2b,us-west-2c"
*   internal_subnets    = "172.16.3.0/24,172.16.4.0/24,172.16.5.0/24"
*   name                = "prod-us-network-layout"
*   k8_cluster_name     = "<kubernetes-quoin-name>"
* }
*
* provider "aws" {
*   region = "us-west-2"
* }
* ```
*
*/

/*
* ------------------------------------------------------------------------------
* Variables
* ------------------------------------------------------------------------------
*/

variable "vpc_id" {
  description = "The ID of the VPC to create the resources within."
}

variable "availability_zones" {
  description = "Comma separated list of availability zones for a region."
}

variable "internal_subnets" {
  description = "Comma separated list of CIDR's to use for the internal subnets."
}

variable "name" {
  description = "A name to tag the resources."
}

variable "k8_cluster_name" {
  description = "The name of your k8 cluster name, i.e. your Kubernetes quoin name"
}

/*
* ------------------------------------------------------------------------------
* Resources
* ------------------------------------------------------------------------------
*/

# Subnets
resource "aws_subnet" "internal" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(split(",", var.internal_subnets), count.index)}"
  availability_zone = "${element(split(",", var.availability_zones), count.index)}"
  count             = "${length(compact(split(",", var.internal_subnets)))}"

  tags {
    Name              = "${var.name}-${format("internal-%03d", count.index+1)}"
    KubernetesCluster = "${var.k8_cluster_name}"
  }
}

/*
* ------------------------------------------------------------------------------
* Outputs
* ------------------------------------------------------------------------------
*/

# A comma-separated list of availability zones for the network.
output "availability_zones" {
  value = "${join(",", aws_subnet.internal.*.availability_zone)}"
}

# A comma-separated list of subnet ids for the internal subnets.
output "internal_subnet_ids" {
  value = "${join(",", aws_subnet.internal.*.id)}"
}
