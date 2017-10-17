/*
* ------------------------------------------------------------------------------
* Resources
* ------------------------------------------------------------------------------
*/

# NOTE: s3 bucket requires global unique bucket name
# Convention: scipian-<name> for the prefix

# s3 bucket for initial-cluster etcd proxy discovery
# and two-stage cloudinit user-data files
resource "aws_s3_bucket" "cluster" {
  bucket        = "${format("scipian-%s", var.name)}"
  acl           = "private"
  force_destroy = true

  tags {
    Name = "${var.name}"
  }
}
