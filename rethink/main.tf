/**
* This module creates a RethinkDB cluster.
*
*
* Usage:
*
* ```hcl
* module "rethink" {
*   source                    = "github.com/scipian/quoins//rethink"
*   availability_zones        = "us-west-2a,us-west-2b,us-west-2c"
*   name                      = "prod-rethink"
*   region                    = "us-west-2"
*   role_type                 = "app1"
*   cost_center               = "1"
*   bastion_security_group_id = "sg-xxxxxxxx"
*   vpc_id                    = "vpc-1234565"
*   vpc_cidr                  = "172.16.0.0/16"
*   subnet_ids                = "subnet-3b018d72,subnet-3bdcb65c,subnet-066e8b5d"
*   (TODO NL: refactor usage example after KMS and Mutli-region support changes have been applied)
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

variable "name" {
  description = "The name of your quoin."
}

variable "version" {
  description = "The version number of your infrastructure, used to aid in zero downtime deployments of new infrastructure."
  default     = "latest"
}

variable "region" {
  description = "Region where resources will be created."
}

variable "role_type" {
  description = "The role type to attach resource usage."
}

variable "cost_center" {
  description = "The cost center to attach resource usage."
}

variable "kms_key_arn" {
  description = "The arn associated with the encryption key used for encrypting the certificates."
}

variable "root_cert" {
  description = "The root certificate authority that all certificates belong to encoded in base64 format."
}

variable "intermediate_cert" {
  description = "The intermediate certificate authority that all certificates belong to encoded in base64 format."
}

variable "vpc_id" {
  description = "The ID of the VPC to create the resources within."
}

variable "vpc_cidr" {
  description = "A CIDR block for the VPC that specifies the set of IP addresses to use."
}

variable "availability_zones" {
  description = "Comma separated list of availability zones for a region."
}

/*
* ------------------------------------------------------------------------------
* Resources
* ------------------------------------------------------------------------------
*/

# Certificates
resource "aws_s3_bucket_object" "root_cert" {
  bucket  = "${aws_s3_bucket.cluster.bucket}"
  key     = "cloudinit/common/tls/root-ca.pem.enc.base"
  content = "${var.root_cert}"
}

resource "aws_s3_bucket_object" "intermediate_cert" {
  bucket  = "${aws_s3_bucket.cluster.bucket}"
  key     = "cloudinit/common/tls/intermediate-ca.pem.enc.base"
  content = "${var.intermediate_cert}"
}

/*
* ------------------------------------------------------------------------------
* Data Sources
* ------------------------------------------------------------------------------
*/

data "template_file" "s3_cloudconfig_bootstrap" {
  template = "${file(format("%s/bootstrapper/s3-cloudconfig-bootstrap.sh", path.module))}"

  vars {
    name = "${var.name}"
  }
}

# Latest stable CoreOS AMI
data "aws_ami" "coreos_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CoreOS-stable-*-hvm"]
  }
}

/*
* ------------------------------------------------------------------------------
* Outputs
* ------------------------------------------------------------------------------
*/

# The name of our quoin
output "name" {
  value = "${var.name}"
}

# The region where the quoin lives
output "region" {
  value = "${var.region}"
}

# The CoreOS AMI ID
output "coreos_ami" {
  value = "${data.aws_ami.coreos_ami.id}"
}
