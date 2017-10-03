/*
* ------------------------------------------------------------------------------
* Variables
* ------------------------------------------------------------------------------
*/

variable "etcd_instance_type" {
  description = "The type of instance to use for the etcd cluster. Example: 'm3.medium'"
  default     = "m3.medium"
}

variable "etcd_min_size" {
  description = "The minimum size for the etcd cluster. NOTE: Use odd numbers."
  default     = "1"
}

variable "etcd_max_size" {
  description = "The maximum size for the etcd cluster. NOTE: Use odd numbers."
  default     = "9"
}

variable "etcd_desired_capacity" {
  description = "The desired capacity of the etcd cluster. NOTE: Use odd numbers."
  default     = "1"
}

variable "etcd_root_volume_size" {
  description = "Set the desired capacity for the root volume in GB."
  default     = "12"
}

variable "etcd_data_volume_size" {
  description = "Set the desired capacity for the data volume used by etcd in GB."
  default     = "12"
}

variable "etcd_encrypt_data_volume" {
  description = "Encrypt data volume used by etcd"
  default     = "true"
}

variable "etcd_aws_operator_image_repo" {
  description = "Docker image repository for the etcd AWS operator image."
  default     = "quay.io/concur_platform/etcd-aws-operator"
}

variable "etcd_aws_operator_version" {
  description = "Version of etcd AWS operator image."
  default     = "0.0.1"
}

/*
* ------------------------------------------------------------------------------
* Modules
* ------------------------------------------------------------------------------
*/

module "etcd" {
  source                        = "../etcd"
  name                          = "${format("%s-etcd", var.name)}"
  region                        = "${var.region}"
  role_type                     = "${var.role_type}"
  cost_center                   = "${var.cost_center}"
  vpc_id                        = "${var.vpc_id}"
  vpc_cidr                      = "${var.vpc_cidr}"
  availability_zones            = "${var.availability_zones}"
  subnet_ids                    = "${var.internal_subnet_ids}"
  key_name                      = "${module.key_pair.key_name}"
  tls_provision                 = "${var.tls_provision}"
  etcd_instance_type            = "${var.etcd_instance_type}"
  etcd_min_size                 = "${var.etcd_min_size}"
  etcd_max_size                 = "${var.etcd_max_size}"
  etcd_desired_capacity         = "${var.etcd_desired_capacity}"
  etcd_root_volume_size         = "${var.etcd_root_volume_size}"
  etcd_data_volume_size         = "${var.etcd_data_volume_size}"
  bastion_security_group_id     = "${var.bastion_security_group_id}"
  assume_role_principal_service = "${var.assume_role_principal_service}"
  arn_region                    = "${var.arn_region}"
  etcd_encrypt_data_volume      = "${var.etcd_encrypt_data_volume}"
  http_proxy                    = "${var.http_proxy}"
  https_proxy                   = "${var.https_proxy}"
  no_proxy                      = "${var.no_proxy}"
  aws_cli_image_repo            = "${var.aws_cli_image_repo}"
  aws_cli_version               = "${var.aws_cli_version}"
  etcd_aws_operator_image_repo  = "${var.etcd_aws_operator_image_repo}"
  etcd_aws_operator_version     = "${var.etcd_aws_operator_version}"
}
