# Bastion

This module creates a bastion instance. The bastion host acts as the
"jump point" for the rest of the infrastructure. Since most of our
instances aren't exposed to the external internet, the bastion acts as
the gatekeeper for any direct SSH access. The bastion is provisioned using
the key name that you pass to the module (and hopefully have stored somewhere).
If you ever need to access an instance directly, you can do it by
"jumping through" the bastion.

Usage:

```hcl
module "bastion" {
  source                = "github.com/scipian/quoins//bastion"
  availability_zone     = "us-west-2a"
  bastion_ami_id        = "ami-*****"
  bastion_key_name      = "ssh-key"
  security_group_ids    = "sg-*****,sg-*****"
  subnet_id             = "pub-1"
  cost_center           = "1000"
  role_type             = "abcd"
  name                  = "quoin-bastion"
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| availability_zone | An availability zone to launch the instance. | string | - | yes |
| bastion_ami_id | The ID Amazon Machine Image (AMI) to use for the instance. | string | - | yes |
| bastion_instance_type | Instance type, see a list at: https://aws.amazon.com/ec2/instance-types/ | string | `t2.micro` | no |
| bastion_key_name | The name of the SSH key pair to use for the bastion. | string | - | yes |
| cost_center | The cost center to attach resource usage. | string | - | yes |
| name | A name to prefix the bastion tag. | string | - | yes |
| role_type | The role type to attach resource usage. | string | - | yes |
| security_group_ids | A comma separated lists of security group IDs | string | - | yes |
| subnet_id | An external subnet id. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| bastion_external_ip | Bastion external IP address |

# ELB External

This module creates an elastic load balancer to be used by instances for exposing services.

Usage:

```hcl
module "elb-unsecure" {
  source             = "github.com/scipian/quoins//elb-external"
  name               = "elb-unsecure"
  vpc_id             = "vpc-123456"
  subnet_ids         = "subnet-123456,subnet-123457,subnet-123458"
  lb_port            = "80"
  instance_port      = "30000"
  healthcheck        = "/health"
  protocol           = "HTTP"
  instance_protocol  = "HTTP"
}

module "elb-secure" {
  source             = "github.com/scipian/quoins//elb-external"
  name               = "elb-secure"
  vpc_id             = "vpc-123456"
  subnet_ids         = "subnet-123456,subnet-123457,subnet-123458"
  lb_port            = "443"
  instance_port      = "30000"
  healthcheck        = "/health"
  protocol           = "HTTPS"
  instance_protocol  = "HTTP"
  ssl_certificate_id = "arn:aws:..."
}

provider "aws" {
  region = "us-west-2"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| healthcheck | Healthcheck path | string | - | yes |
| instance_port | Instance port | string | - | yes |
| instance_protocol | Protocol to use, HTTPS, HTTP or TCP | string | - | yes |
| lb_port | Load balancer port | string | - | yes |
| name | ELB name, e.g cdn | string | - | yes |
| protocol | Protocol to use, HTTPS, HTTP or TCP | string | - | yes |
| ssl_certificate_id | The ARN of an SSL certificate you have uploaded to AWS IAM. | string | - | yes |
| subnet_ids | Comma separated list of subnet IDs | string | - | yes |
| vpc_id | The ID of the VPC to create the resources within. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns | The ELB dns_name. |
| id | The ELB ID. |
| name | The ELB name. |

# ELB Internal

This module creates an internal elastic load balancer to be used by instances for exposing services.

Usage:

```hcl
module "elb-unsecure" {
  source             = "github.com/scipian/quoins//elb-internal"
  name               = "elb-unsecure"
  vpc_id             = "vpc-123456"
  subnet_ids         = "subnet-123456,subnet-123457,subnet-123458"
  lb_port            = "80"
  instance_port      = "30000"
  healthcheck        = "/health"
  protocol           = "HTTP"
  instance_protocol  = "HTTP"
}

module "elb-secure" {
  source             = "github.com/scipian/quoins//elb-internal"
  name               = "elb-secure"
  vpc_id             = "vpc-123456"
  subnet_ids         = "subnet-123456,subnet-123457,subnet-123458"
  lb_port            = "443"
  instance_port      = "30000"
  healthcheck        = "/health"
  protocol           = "HTTPS"
  instance_protocol  = "HTTP"
  ssl_certificate_id = "arn:aws:..."
}

provider "aws" {
  region = "us-west-2"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| healthcheck | Healthcheck path | string | - | yes |
| instance_port | Instance port | string | - | yes |
| instance_protocol | Protocol to use, HTTPS, HTTP or TCP | string | - | yes |
| lb_port | Load balancer port | string | - | yes |
| name | ELB name, e.g cdn | string | - | yes |
| protocol | Protocol to use, HTTPS, HTTP or TCP | string | - | yes |
| ssl_certificate_id | The ARN of an SSL certificate you have uploaded to AWS IAM. | string | - | yes |
| subnet_ids | Comma separated list of subnet IDs | string | - | yes |
| vpc_id | The ID of the VPC to create the resources within. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns | The ELB dns_name. |
| id | The ELB ID. |
| name | The ELB name. |

# ETCD

This module creates an etcd cluster.

Usage:

```hcl
module "etcd" {
  source                    = "github.com/scipian/quoins//etcd"
  name                      = "elb-unsecure"
  availability_zones        = "us-west-2a,us-west-2b,us-west-2c"
  bastion_security_group_id = "sg-****"
  cost_center               = "1000"
  key_name                  = "quoin-etcd"
  name                      = "prod-us-etcd"
  region                    = "us-west-2"
  role_type                 = "abcd"
  subnet_ids                = "pub-1,pub-2,pub-3"
  tls_provision             = "${file(format("%s/../provision.sh", path.cwd))}"
  vpc_cidr                  = "172.16.0.0/16"
  vpc_id                    = "vpc-123456"
}

provider "aws" {
  region = "us-west-2"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| arn_region | Amazon Resource Name based on region, aws for most regions and aws-cn for Beijing | string | `aws` | no |
| assume_role_principal_service | Principal service used for assume role policy. More information can be found at https://docs.aws.amazon.com/general/latest/gr/rande.html#iam_region. | string | `ec2.amazonaws.com` | no |
| availability_zones | Comma separated list of availability zones for a region. | string | - | yes |
| aws_cli_image_repo | Docker image repository for the AWS CLI image. | string | `quay.io/concur_platform/awscli` | no |
| aws_cli_version | Version of AWS CLI image. | string | `0.1.1` | no |
| bastion_security_group_id | Security Group ID for bastion instance with external SSH allows ssh connections on port 22 | string | - | yes |
| coreos_channel | Channel for CoreOS version (https://coreos.com/releases). | string | `stable` | no |
| coreos_version | CoreOS version (https://coreos.com/releases). | string | `1465.8.0` | no |
| cost_center | The cost center to attach resource usage. | string | - | yes |
| etcd_aws_operator_image_repo | Docker image repository for the etcd AWS operator image. | string | `quay.io/concur_platform/etcd-aws-operator` | no |
| etcd_aws_operator_version | Version of etcd AWS operator image. | string | `0.0.1` | no |
| etcd_data_volume_size | Set the desired capacity for the data volume used by etcd in GB. | string | `12` | no |
| etcd_desired_capacity | The desired capacity of the etcd cluster. NOTE: Use odd numbers. | string | `1` | no |
| etcd_encrypt_data_volume | Encrypt data volume used by etcd. | string | `true` | no |
| etcd_image_repo | Docker image repository for etcd image | string | `quay.io/coreos/etcd` | no |
| etcd_image_version | Version of etcd image | string | `v3.1.5` | no |
| etcd_instance_type | The type of instance to use for the etcd cluster. Example: 'm3.medium' | string | `m3.medium` | no |
| etcd_max_size | The maximum size for the etcd cluster. NOTE: Use odd numbers. | string | `9` | no |
| etcd_min_size | The minimum size for the etcd cluster. NOTE: Use odd numbers. | string | `1` | no |
| etcd_root_volume_size | Set the desired capacity for the root volume in GB. | string | `12` | no |
| http_proxy | Proxy server to use for http. | string | `` | no |
| https_proxy | Proxy server to use for https. | string | `` | no |
| key_name | A name for the given key pair to use for instances. | string | - | yes |
| name | The name of your quoin. | string | - | yes |
| no_proxy | List of domains or IP's that do not require a proxy. | string | `` | no |
| region | Region where resources will be created. | string | - | yes |
| role_type | The role type to attach resource usage. | string | - | yes |
| subnet_ids | A comma-separated list of subnet ids to use for the instances. | string | - | yes |
| tls_provision | The TLS ca and assets provision script. | string | - | yes |
| version | The version number of your infrastructure, used to aid in zero downtime deployments of new infrastructure. | string | `latest` | no |
| vpc_cidr | A CIDR block for the VPC that specifies the set of IP addresses to use. | string | - | yes |
| vpc_id | The ID of the VPC to create the resources within. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| coreos_ami | The CoreOS AMI ID |
| name | The name of our quoin |
| region | The region where the quoin lives |

# External-Internal-Layout

This module creates a network layout with the following resources
inside a network:

1. An external subnet for each availability zone in a region.
2. An internal subnet for each availability zone in a region.
3. An nat gateway to route traffic from the internal subnets to the internet.

Usage:

```hcl
module "network_layout" {
  source              = "github.com/scipian/quoins//external-internal-layout"
  vpc_id              = "vpc-*****"
  internet_gateway_id = "igw-*****"
  availability_zones  = "us-west-2a,us-west-2b,us-west-2c"
  external_subnets    = "172.16.0.0/24,172.16.1.0/24,172.16.2.0/24"
  internal_subnets    = "172.16.3.0/24,172.16.4.0/24,172.16.5.0/24"
  name                = "prod-us-network-layout"
  k8_cluster_name     = "<kubernetes-quoin-name>"
}

provider "aws" {
  region = "us-west-2"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| availability_zones | Comma separated list of availability zones for a region. | string | - | yes |
| external_subnets | Comma separated list of CIDR's to use for the external subnets. | string | - | yes |
| internal_subnets | Comma separated list of CIDR's to use for the internal subnets. | string | - | yes |
| internet_gateway_id | The ID of the internet gateway that belongs to the VPC. | string | - | yes |
| k8_cluster_name | The name of your k8 cluster name, i.e. your Kubernetes quoin name | string | - | yes |
| name | A name to tag the resources. | string | - | yes |
| vpc_id | The ID of the VPC to create the resources within. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| availability_zones | A comma-separated list of availability zones for the network. |
| external_rtb_id | The external route table ID. |
| external_subnet_ids | A comma-separated list of subnet ids for the external subnets. |
| internal_rtb_ids | The internal route table ID. |
| internal_subnet_ids | A comma-separated list of subnet ids for the internal subnets. |

# Internal-Layout

This module creates a internal only layout with the following resources
inside a network:

1. An internal subnet for each availability zone in a region.

Usage:

```hcl
module "network_layout" {
  source              = "github.com/scipian/quoins//internal-layout"
  vpc_id              = "vpc-*****"
  availability_zones  = "us-west-2a,us-west-2b,us-west-2c"
  internal_subnets    = "172.16.3.0/24,172.16.4.0/24,172.16.5.0/24"
  name                = "prod-us-network-layout"
  k8_cluster_name     = "<kubernetes-quoin-name>"
}

provider "aws" {
  region = "us-west-2"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| availability_zones | Comma separated list of availability zones for a region. | string | - | yes |
| internal_subnets | Comma separated list of CIDR's to use for the internal subnets. | string | - | yes |
| k8_cluster_name | The name of your k8 cluster name, i.e. your Kubernetes quoin name | string | - | yes |
| name | A name to tag the resources. | string | - | yes |
| vpc_id | The ID of the VPC to create the resources within. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| availability_zones | A comma-separated list of availability zones for the network. |
| internal_subnet_ids | A comma-separated list of subnet ids for the internal subnets. |

# Key-Pair

This module creates a key pair to be used by instances.

Usage:

```hcl
module "ssh_key_pair" {
  source = "github.com/scipian/quoins//key-pair"
  key_name   = "quoin-bastion"
  public_key = "ssh-rsa skdlfjkljasfkdjjkas;dfjksakj ... email@domain.com"
}

provider "aws" {
  region = "us-west-2"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| key_name | A name to give the key pair. | string | - | yes |
| public_key | Public key material in a format supported by AWS: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#how-to-generate-your-own-key-and-import-it-to-aws | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| fingerprint | Fingerprint of given public key |
| key_name | Key name given to key pair |

# Kubernetes

This module creates an opinionated [Kubernetes][kubernetes] cluster in AWS. Currently, this
quoin only supports the AWS provider and has only been tested in the us-west-2 and eu-central-1
regions.

Although terraform is capable of maintaining and altering state of infrastructure, this Quoin is
only intended to stand up new clusters. Please do not attempt to alter the configuration of
existing clusters. We treat our clusters as immutable resources.

[kubernetes]: http://kubernetes.io

The way the cluster is provisioned is by using Terraform configs to create the
appropriate resources in AWS. From that point, we use CoreOS, Auto Scaling Groups
with Launch Configurations to launch the Kubernetes cluster. The cluster is launched in
an air gapped way using only AWS API's, therefore, by default, there isn't a way to SSH
directly to an instance without a bastion. We use our Bastion Quoin to launch on-demand
bastions when the need arises. Currently we launch version 1.2.4 of Kubernetes.

## What's Inside

* Subnets that are dynamic and react to the number of availability zones within the region.
* Reference to a security group for bastions to use.
* CoreOS is used as the host operating system for all instances.
* The certificates are used to completely secure the communication between etcd, controllers, and nodes.
* Creates a dedicated etcd cluster within the private subnets using an auto scaling group.
  * EBS Volumes:
    * Root block store device
    * Encrypted block store for etcd data mounted at /var/lib/etcd2
* Creates a Kubernetes control plane within the private subnets using an auto scaling group.
  * An ELB attached to each instance to allow external access to the API.
  * EBS Volumes:
    * Root block store device
    * Encrypted block store for Docker mounted at /var/lib/docker
* Creates a Kubernetes nodes within the private subnets using an auto scaling group.
  * EBS Volumes:
    * Root block store device
    * Encrypted block store for Docker mounted at /var/lib/docker
    * Encrypted block store for data mounted at /opt/data
    * Encrypted block store for logging mounted at /opt/logging
* Systemd timer to garbage collect docker images and containers daily.
* Systemd timer to logrotate docker logs hourly.
* Creates an ssh key pair for the cluster using the passed in public key.
* s3 bucket for the cluster where configs are saved for ASG and also allows the cluster to use it for backups.
* IAM roles to give instances permission to access resources based on their role
* Fluent/ElasticSearch/Kibana runs within the cluster to ship all logs to a central location. Only thing needed by the developer is to log to stdout or stderr.

Usage:

```hcl
module "kubernetes" {
  source                                = "github.com/scipian/quoins//kubernetes"
  name                                  = "prod"
  role_type                             = "app1"
  cost_center                           = "1"
  region                                = "us-west-2"
  vpc_id                                = "vpc-1234565"
  vpc_cidr                              = "172.16.0.0/16"
  availability_zones                    = "us-west-2a,us-west-2b,us-west-2c"
  elb_subnet_ids                        = "subnet-3b018d72,subnet-3bdcb65c,subnet-066e8b5d"
  internal_subnet_ids                   = "subnet-3b018d72,subnet-3bdcb65c,subnet-066e8b5d"
  public_key                            = "${file(format("%s/keys/%s.pub", path.cwd, var.name))}"
  tls_provision                         = "${file(format("%s/../provision.sh", path.cwd))}"
  bastion_security_group_id             = "sg-xxxxxxxx"
}

provider "aws" {
  region = "us-west-2"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| arn_region | Amazon Resource Name based on region, aws for most regions and aws-cn for Beijing | string | `aws` | no |
| assume_role_principal_service | Principal service used for assume role policy. More information can be found at https://docs.aws.amazon.com/general/latest/gr/rande.html#iam_region. | string | `ec2.amazonaws.com` | no |
| availability_zones | Comma separated list of availability zones for a region. | string | - | yes |
| aws_cli_image_repo | Docker image repository for the AWS CLI image. | string | `quay.io/concur_platform/awscli` | no |
| aws_cli_version | Version of AWS CLI image. | string | `0.1.1` | no |
| bastion_security_group_id | Security Group ID for bastion instance with external SSH allows ssh connections on port 22 | string | - | yes |
| controller_desired_capacity | The desired capacity of the controller cluster. | string | `1` | no |
| controller_docker_volume_size | Set the desired capacity for the docker volume in GB. | string | `12` | no |
| controller_encrypt_docker_volume | Encrypt docker volume used by controller. | string | `true` | no |
| controller_instance_type | The type of instance to use for the controller cluster. Example: 'm3.medium' | string | `m3.medium` | no |
| controller_kube_apiserver_environment | Environment for Kubernetes apiserver pod. | string | `` | no |
| controller_kube_controller_manager_environment | Environment for Kubernetes controller manager pod. | string | `` | no |
| controller_kube_proxy_environment | Environment for Kubernetes proxy pod. | string | `` | no |
| controller_kube_scheduler_environment | Environment for Kubernetes scheduler pod. | string | `` | no |
| controller_max_size | The maximum size for the controller cluster. | string | `3` | no |
| controller_min_size | The minimum size for the controller cluster. | string | `1` | no |
| controller_root_volume_size | Set the desired capacity for the root volume in GB. | string | `12` | no |
| coreos_channel | Channel for CoreOS version (https://coreos.com/releases). | string | `stable` | no |
| coreos_version | CoreOS version (https://coreos.com/releases). | string | `1465.8.0` | no |
| cost_center | The cost center to attach resource usage. | string | - | yes |
| elb_subnet_ids | A comma-separated list of subnet ids to use for the k8s API. | string | - | yes |
| etcd_aws_operator_image_repo | Docker image repository for the etcd AWS operator image. | string | `quay.io/concur_platform/etcd-aws-operator` | no |
| etcd_aws_operator_version | Version of etcd AWS operator image. | string | `0.0.1` | no |
| etcd_data_volume_size | Set the desired capacity for the data volume used by etcd in GB. | string | `12` | no |
| etcd_desired_capacity | The desired capacity of the etcd cluster. NOTE: Use odd numbers. | string | `1` | no |
| etcd_encrypt_data_volume | Encrypt data volume used by etcd | string | `true` | no |
| etcd_instance_type | The type of instance to use for the etcd cluster. Example: 'm3.medium' | string | `m3.medium` | no |
| etcd_max_size | The maximum size for the etcd cluster. NOTE: Use odd numbers. | string | `9` | no |
| etcd_min_size | The minimum size for the etcd cluster. NOTE: Use odd numbers. | string | `1` | no |
| etcd_root_volume_size | Set the desired capacity for the root volume in GB. | string | `12` | no |
| exechealthz_image_repo | Docker image repository for exec healthz image. | string | `gcr.io/google_containers/exechealthz-amd64` | no |
| exechealthz_version | Version of exec healthz | string | `1.2` | no |
| flannel_image_repo | Docker image repository for flannel image | string | `quay.io/coreos/flannel` | no |
| flannel_image_version | Version of flannel image | string | `v0.7.1` | no |
| http_proxy | Proxy server to use for http. | string | `` | no |
| https_proxy | Proxy server to use for https. | string | `` | no |
| internal_subnet_ids | A comma-separated list of subnet ids to use for the instances. | string | - | yes |
| is_k8s_elb_internal | Specify if the k8s API is internal or external facing. | string | `false` | no |
| kubedns_image_repo | Docker image repository for kube dns image. | string | `gcr.io/google_containers/kubedns-amd64` | no |
| kubedns_version | Version of kubedns | string | `1.8` | no |
| kubednsmasq_image_repo | Docker image repository for kube dnsmasq image. | string | `gcr.io/google_containers/kube-dnsmasq-amd64` | no |
| kubednsmasq_version | Version of kubednsmasq | string | `1.4` | no |
| kubernetes_dns_service_ip | The IP Address of the Kubernetes DNS service. NOTE: Must be contained by the Kubernetes Service CIDR. | string | `10.3.0.10` | no |
| kubernetes_hyperkube_image_repo | The hyperkube image repository to use. | string | `quay.io/coreos/hyperkube` | no |
| kubernetes_pod_cidr | A CIDR block that specifies the set of IP addresses to use for Kubernetes pods. | string | `10.2.0.0/16` | no |
| kubernetes_service_cidr | A CIDR block that specifies the set of IP addresses to use for Kubernetes services. | string | `10.3.0.1/24` | no |
| kubernetes_version | The version of the hyperkube image to use. This is the tag for the hyperkube image repository | string | `v1.6.2_coreos.0` | no |
| name | The name of your quoin. | string | - | yes |
| no_proxy | List of domains or IP's that do not require a proxy. | string | `` | no |
| node_data_volume_size | Set the desired capacity for the data volume in GB. | string | `12` | no |
| node_desired_capacity | The desired capacity of the node cluster. | string | `1` | no |
| node_docker_volume_size | Set the desired capacity for the docker volume in GB. | string | `12` | no |
| node_encrypt_data_volume | Encrypt data volume used by node. | string | `true` | no |
| node_encrypt_docker_volume | Encrypt docker volume used by node. | string | `true` | no |
| node_encrypt_logging_volume | Encrypt logging volume used by node. | string | `true` | no |
| node_instance_type | The type of instance to use for the node cluster. Example: 'm3.medium' | string | `m3.medium` | no |
| node_kube_proxy_environment | Environment for Kubernetes proxy pod. | string | `` | no |
| node_logging_volume_size | Set the desired capacity for the logging volume in GB. | string | `12` | no |
| node_max_size | The maximum size for the node cluster. | string | `12` | no |
| node_min_size | The minimum size for the node cluster. | string | `1` | no |
| node_root_volume_size | Set the desired capacity for the root volume in GB. | string | `12` | no |
| pod_infra_image_repo | Docker image repository for the pod infra image. | string | `gcr.io/google_containers/pause-amd64` | no |
| pod_infra_version | Version of pod infra | string | `3.0` | no |
| public_key | The public key to apply to instances in the cluster. | string | - | yes |
| region | Region where resources will be created. | string | - | yes |
| role_type | The role type to attach resource usage. | string | - | yes |
| tls_provision | The TLS ca and assets provision script. | string | - | yes |
| version | The version number of your infrastructure, used to aid in zero downtime deployments of new infrastructure. | string | `latest` | no |
| vpc_cidr | A CIDR block for the VPC that specifies the set of IP addresses to use. | string | - | yes |
| vpc_id | The ID of the VPC to create the resources within. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| coreos_ami | The CoreOS AMI ID |
| key_pair_name | The name of the key pair |
| kubernetes_api_dns | The ELB DNS in which you can access the Kubernetes API. |
| name | The name of our quoin |
| region | The region where the quoin lives |

# Network

This module creates a single virtual network and routes traffic in and out of
the network by creating an internet gateway within a given region.

Usage:

```hcl
module "network" {
  source = "github.com/scipian/quoins//network"
  cidr   = "172.16.0.0/16"
  name   = "prod-us-network"
}

provider "aws" {
  region = "us-west-2"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cidr | A CIDR block for the network. | string | `172.16.0.0/16` | no |
| enable_dns_hostnames | Enable/Disable DNS hostnames in the VPC. | string | `true` | no |
| enable_dns_support | Enable/Disable DNS support in the VPC. | string | `true` | no |
| name | A name to tag the network. | string | `quoin-network` | no |

## Outputs

| Name | Description |
|------|-------------|
| default_security_group_id | The Network Security Group ID |
| internet_gateway_id | The Internet Gateway ID |
| vpc_cidr | The CIDR used for the network |
| vpc_id | The Network ID |

# Rethink

This module creates a RethinkDB cluster.

Usage:

```hcl
module "rethink" {
  source                    = "github.com/scipian/quoins//rethink"
  availability_zones        = "us-west-2a,us-west-2b,us-west-2c"
  name                      = "prod-rethink"
  region                    = "us-west-2"
  role_type                 = "app1"
  cost_center               = "1"
  bastion_security_group_id = "sg-xxxxxxxx"
  vpc_id                    = "vpc-1234565"
  vpc_cidr                  = "172.16.0.0/16"
  subnet_ids                = "subnet-3b018d72,subnet-3bdcb65c,subnet-066e8b5d"
  (TODO NL: refactor usage example after KMS and Mutli-region support changes have been applied)
}

provider "aws" {
  region = "us-west-2"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| availability_zones | Comma separated list of availability zones for a region. | string | - | yes |
| bastion_security_group_id | Security Group ID for bastion instance with external SSH allows ssh connections on port 22 | string | - | yes |
| cost_center | The cost center to attach resource usage. | string | - | yes |
| intermediate_cert | The intermediate certificate authority that all certificates belong to encoded in base64 format. | string | - | yes |
| key_name | A name for the given key pair to use for instances. | string | - | yes |
| kms_key_arn | The arn associated with the encryption key used for encrypting the certificates. | string | - | yes |
| name | The name of your quoin. | string | - | yes |
| region | Region where resources will be created. | string | - | yes |
| rethink_cluster_cert | The public certificate to be used by rethink servers for peer connections encoded in base64 format. | string | - | yes |
| rethink_cluster_key | The private key to be used by rethink servers for peer connections encoded in base64 format. | string | - | yes |
| rethink_data_volume_size | Set the desired capacity for the rethink data volume in GB. | string | `12` | no |
| rethink_desired_capacity | The desired capacity of the rethink cluster. NOTE: Use odd numbers. | string | `1` | no |
| rethink_docker_volume_size | Set the desired capacity for the docker volume in GB. | string | `12` | no |
| rethink_driver_cert | The public certificate to be used by rethink servers for driver connections encoded in base64 format. | string | - | yes |
| rethink_driver_cert_plain | The public certificate to be used by ELB backend authentication for driver connections encoded in pem format. | string | - | yes |
| rethink_driver_key | The private key to be used by rethink servers for driver connections encoded in base64 format. | string | - | yes |
| rethink_elb_cert | The public certificate to be used by the ELB that fronts rethink instances encoded in PEM format. | string | - | yes |
| rethink_elb_key | The private key to be used by the ELB that fronts rethink instances encode in PEM format. | string | - | yes |
| rethink_instance_type | The type of instance to use for the rethink cluster. Example: 'm3.medium' | string | `m3.medium` | no |
| rethink_max_size | The maximum size for the rethink cluster. NOTE: Use odd numbers. | string | `9` | no |
| rethink_min_size | The minimum size for the rethink cluster. NOTE: Use odd numbers. | string | `1` | no |
| rethink_root_volume_size | Set the desired capacity for the root volume in GB. | string | `12` | no |
| role_type | The role type to attach resource usage. | string | - | yes |
| root_cert | The root certificate authority that all certificates belong to encoded in base64 format. | string | - | yes |
| subnet_ids | A comma-separated list of subnet ids to use for the instances. | string | - | yes |
| version | The version number of your infrastructure, used to aid in zero downtime deployments of new infrastructure. | string | `latest` | no |
| vpc_cidr | A CIDR block for the VPC that specifies the set of IP addresses to use. | string | - | yes |
| vpc_id | The ID of the VPC to create the resources within. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| coreos_ami | The CoreOS AMI ID |
| name | The name of our quoin |
| region | The region where the quoin lives |
| rethink_dns | The ELB DNS in which you can access Vault. |

# Security Groups

This module creates basic security groups to be used by instances.

Usage:

```hcl
module "security_groups" {
  source = "github.com/scipian/quoins//security-groups"
  vpc_id = "vpc-*****"
  name   = "quoin"
}

provider "aws" {
  region = "us-west-2"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | A name to prefix security groups. | string | - | yes |
| vpc_id | The ID of the VPC to create the security groups on. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| external_ssh | External SSH allows ssh connections on port 22 |
| external_win_remote | External Windows Remote allows remote connections on ports 3389, 5986, & 5985 |

# Vault

This module creates a Vault cluster.

Usage:

```hcl
module "vault" {
  source                    = "github.com/scipian/quoins//vault"
  availability_zones        = "us-west-2a,us-west-2b,us-west-2c"
  name                      = "prod-rethink"
  region                    = "us-west-2"
  role_type                 = "app1"
  cost_center               = "1"
  bastion_security_group_id = "sg-xxxxxxxx"
  vpc_id                    = "vpc-1234565"
  vpc_cidr                  = "172.16.0.0/16"
  subnet_ids                = "subnet-3b018d72,subnet-3bdcb65c,subnet-066e8b5d"
  intermediate_cert         = "${file(format("%s/tls/intermediate-ca.pem.enc.base", path.cwd))}"
  key_name                  = "vault"
  root_cert                 = "${file(format("%s/tls/root-ca.pem.enc.base", path.cwd))}"
  vault_elb_cert            = "${file(format("%s/tls/vault_elb.pem", path.cwd))}"
  vault_elb_key             = "${file(format("%s/tls/vault_elb_key.pem", path.cwd))}"
  vault_etcd_client_cert    = "${file(format("%s/tls/vault_etcd_client.pem.enc.base", path.cwd))}"
  vault_etcd_client_key     = "${file(format("%s/tls/vault_etcd_client_key.pem.enc.base", path.cwd))}"
  vault_server_cert         = "${file(format("%s/tls/vault_server.pem.enc.base", path.cwd))}"
  vault_server_cert_plain   = "${file(format("%s/tls/vault_server_plain.pem", path.cwd))}"
  vault_server_key          = "${file(format("%s/tls/vault_server_key.pem.enc.base", path.cwd))}"
}

provider "aws" {
  region = "us-west-2"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| availability_zones | Comma separated list of availability zones for a region. | string | - | yes |
| bastion_security_group_id | Security Group ID for bastion instance with external SSH allows ssh connections on port 22 | string | - | yes |
| cost_center | The cost center to attach resource usage. | string | - | yes |
| etcd_cluster_quoin_name | A name for a running etcd cluster used by vault. | string | - | yes |
| intermediate_cert | The intermediate certificate authority that all certificates belong to encoded in base64 format. | string | - | yes |
| key_name | A name for the given key pair to use for instances. | string | - | yes |
| kms_key_arn | The arn associated with the encryption key used for encrypting the certificates. | string | - | yes |
| name | The name of your quoin. | string | - | yes |
| region | Region where resources will be created. | string | - | yes |
| role_type | The role type to attach resource usage. | string | - | yes |
| root_cert | The root certificate authority that all certificates belong to encoded in base64 format. | string | - | yes |
| subnet_ids | A comma-separated list of subnet ids to use for the instances. | string | - | yes |
| vault_desired_capacity | The desired capacity of the vault cluster. NOTE: Use odd numbers. | string | `1` | no |
| vault_docker_volume_size | Set the desired capacity for the docker volume in GB. | string | `12` | no |
| vault_elb_cert | The public certificate to be used by the ELB that fronts vault instances encoded in PEM format. | string | - | yes |
| vault_elb_key | The private key to be used by the ELB that fronts vault instances encode in PEM format. | string | - | yes |
| vault_etcd_client_cert | The public client certificate to be used for authenticating against etcd encoded in base64 format. | string | - | yes |
| vault_etcd_client_key | The client private key to be used for authenticating against etcd encoded in base64 format. | string | - | yes |
| vault_instance_type | The type of instance to use for the vault cluster. Example: 'm3.medium' | string | `m3.medium` | no |
| vault_max_size | The maximum size for the vault cluster. NOTE: Use odd numbers. | string | `3` | no |
| vault_min_size | The minimum size for the vault cluster. NOTE: Use odd numbers. | string | `1` | no |
| vault_root_volume_size | Set the desired capacity for the root volume in GB. | string | `12` | no |
| vault_server_cert | The public certificate to be used by vault servers encoded in base64 format. | string | - | yes |
| vault_server_cert_plain | The public certificate to be used by vault servers encoded in PEM format. | string | - | yes |
| vault_server_key | The private key to be used by vault servers encoded in base64 format. | string | - | yes |
| version | The version number of your infrastructure, used to aid in zero downtime deployments of new infrastructure. | string | `latest` | no |
| vpc_cidr | A CIDR block for the VPC that specifies the set of IP addresses to use. | string | - | yes |
| vpc_id | The ID of the VPC to create the resources within. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| coreos_ami | The CoreOS AMI ID |
| name | The name of our quoin |
| region | The region where the quoin lives |
| vault_dns | The ELB DNS in which you can access the vault internally. |
