/*
* ------------------------------------------------------------------------------
* Variables
* ------------------------------------------------------------------------------
*/

variable "name" {
  description = "ALB name"
}

variable "vpc_id" {
  description = "The ID of the VPC to create the resources within."
}

variable "subnet_ids" {
  description = "Comma separated list of subnet IDs"
}

variable "enable_deletion_protection" {
  default     = true
  description = "Whether or not to enable ALB deletion via Terraform"
}

variable "enable_access_logs" {
  default     = true
  description = "Whether or not to enable ALB access logs"
}

variable "listener_port" {
  description = "The port the load balancer listens on"
}

variable "listener_protocol" {
  description = "The protocol for connections from clients to the load balancer"
}

variable "ssl_policy" {
  description = "The name of the SSL policy for the listener"
}

variable "certificate_arn" {
  description = "The ARN of the default SSL server certificate"
}

variable "target_group_port" {
  description = "The port the target group receives traffic on"
}

variable "target_group_protocol" {
  description = "The protocol to use for routing traffic to the target group"
}

variable "health_check_path" {
  description = "The destination for the health check request"
}

/*
* ------------------------------------------------------------------------------
* Data
* ------------------------------------------------------------------------------
*/

// Retrieves the Account ID of the AWS ELB Service account in a given region
data "aws_elb_service_account" "main" {}

/*
* ------------------------------------------------------------------------------
* Resources
* ------------------------------------------------------------------------------
*/

resource "aws_security_group" "external_alb" {
  name        = "${format("%s-external-alb", var.name)}"
  vpc_id      = "${var.vpc_id}"
  description = "Allows external ALB traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }

  tags {
    Name = "${format("%s-external-alb", var.name)}"
  }
}

resource "aws_s3_bucket" "access-logs" {
  bucket = "${format("%s-access-logs", var.name)}"
  acl    = "private"

  policy = <<POLICY
{
  "Id":  "${format("%s-access-logs", var.name)}",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${format("%s-access-logs", var.name)}/AWSLogs/*",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.main.arn}"
      }
    }
  ]
}
  POLICY

  tags {
    Name = "${format("%s-access-logs", var.name)}"
  }
}

resource "aws_lb" "external" {
  name            = "${var.name}"
  internal        = false
  subnets         = ["${split(",", var.subnet_ids)}"]
  security_groups = ["${aws_security_group.external_alb.id}"]

  idle_timeout    = 60

  enable_deletion_protection = "${var.enable_deletion_protection}"

  access_logs {
    bucket  = "${aws_s3_bucket.access-logs.id}"
    enabled = "${var.enable_access_logs}"
  }

  tags {
    Name = "${format("%s-external-alb", var.name)}"
  }
}

resource "aws_lb_target_group" "target" {
  name     = "${format("%s-target-group-alb", var.name)}"
  port     = "${var.target_group_port}"
  protocol = "${var.target_group_protocol}"
  vpc_id   = "${var.vpc_id}"

  tags {
    name = "${format("%s-target-group-alb", var.name)}"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "${var.health_check_path}"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_lb.external.arn}"
  port              = "${var.listener_port}"
  protocol          = "${var.listener_protocol}"
  ssl_policy        = "${var.ssl_policy}"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_lb_target_group.target.arn}"
    type             = "forward"
  }
}

/*
* ------------------------------------------------------------------------------
* Outputs
* ------------------------------------------------------------------------------
*/

# The ELB name.
output "name" {
  value = "${aws_lb.external.name}"
}

# The ELB ID.
output "id" {
  value = "${aws_lb.external.id}"
}

# The ELB dns_name.
output "dns" {
  value = "${aws_lb.external.dns_name}"
}
