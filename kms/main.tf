/*
* ------------------------------------------------------------------------------
* Variables
* ------------------------------------------------------------------------------
*/

variable "name" {
  description = "The name of your quoin."
}

variable "region" {
  description = "Region where resources will be created."
}

/*
* ------------------------------------------------------------------------------
* Providers
* ------------------------------------------------------------------------------
*/

provider "aws" {
  region      = "${var.region}"
  max_retries = 3
}

/*
* ------------------------------------------------------------------------------
* Resources
* ------------------------------------------------------------------------------
*/

resource "aws_kms_key" "main" {
  deletion_window_in_days = "7"
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.name}"
  target_key_id = "${aws_kms_key.main.key_id}"
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

# The ARN for the KMS key
output "kms_key_arn" {
  value = "${aws_kms_key.main.arn}"
}

# The ID for the KMS key
output "kms_key_id" {
  value = "${aws_kms_key.main.key_id}"
}

# The ARN for the KMS Alias
output "kms_alias_arn" {
  value = "${aws_kms_alias.main.arn}"
}