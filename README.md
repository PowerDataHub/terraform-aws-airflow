[![Maintained by Powerdatahub.com](https://img.shields.io/badge/maintained%20by-powerdatahub.com-%233D4DFE.svg?style=for-the-badge)](https://powerdatahub.com/?ref=repo_aws_airflow) [![Apache Airflow 1.10.3](https://img.shields.io/badge/Apache%20Airflow-1.10.3-3D4DFE.svg?style=for-the-badge)](https://github.com/apache/airflow/)

# Airflow AWS Module
Terraform module to deploy an [Apache Airflow](https://airflow.apache.org/) cluster on AWS, backed by RDS PostgreSQL for metadata, [S3](https://aws.amazon.com/s3/) for logs and [SQS](https://aws.amazon.com/sqs/) as message broker with CeleryExecutor

<img src="https://raw.githubusercontent.com/PowerDataHub/terraform-aws-airflow/master/terraform-aws-airflow.png?raw" align="center" width="100%" />

### Terraform supported versions:

| Terraform version | Tag  | 
|-------------------|------|
| <= 0.11              | v0.7.x|
| >= 0.12              | v0.8.x|

## Usage

You can use this module from the [Terraform Registry](https://registry.terraform.io/modules/powerdatahub/airflow/aws/)

```terraform
module "airflow-cluster" {
  # REQUIRED
  source                   = "powerdatahub/airflow/aws"
  key_name                 = "airflow-key"
  cluster_name             = "my-airflow"
  cluster_stage            = "prod" # Default is 'dev'
  db_password              = "your-rds-master-password"
  fernet_key               = "your-fernet-key" # see https://airflow.readthedocs.io/en/stable/howto/secure-connections.html
  
  # OPTIONALS
  vpc_id                   = "some-vpc-id"                     # Use default if not provided  
  custom_requirements      = "path/to/custom/requirements.txt" # See examples/custom_requirements for more details
  custom_env               = "path/to/custom/env"              # See examples/custom_env for more details
  ingress_cidr_blocks      = ["0.0.0.0/0"]                     # List of IPv4 CIDR ranges to use on all ingress rules
  ingress_with_cidr_blocks = [                                 # List of computed ingress rules to create where 'cidr_blocks' is used
    {
      description = "List of computed ingress rules for Airflow webserver"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "List of computed ingress rules for Airflow flower"
      from_port   = 5555
      to_port     = 5555
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags                     = {
    FirstKey  = "first-value"                                  # Additional tags to use on resources
    SecondKey = "second-value"
  }
  load_example_dags        = false
  load_default_conns       = false
  rbac                     = true                              # See examples/rbac for more details
  admin_name               = "John"                            # Only if rbac is true
  admin_lastname           = "Doe"                             # Only if rbac is true
  admin_email              = "admin@admin.com"                 # Only if rbac is true
  admin_username           = "admin"                           # Only if rbac is true
  admin_password           = "supersecretpassword"             # Only if rbac is true
}
```

## Debug and logs

The Airflow service runs under systemd, so logs are available through journalctl.

`$ journalctl -u airflow -n 50`

## Todo

- [x] Run airflow as systemd service
- [x] Provide a way to pass a custom requirements.txt files on provision step
- [ ] Provide a way to pass a custom packages.txt files on provision step
- [x] RBAC
- [ ] Support for [Google OAUTH ](https://incubator-airflow.readthedocs.io/en/latest/security.html#google-authentication)
- [x] Flower
- [ ] Secure Flower install 
- [x] Provide a way to inject environment variables into airflow
- [ ] Split services into multiples files
- [ ] Auto Scalling for workers
- [ ] Use SPOT instances for workers
- [ ] Maybe use the [AWS Fargate](https://aws.amazon.com/pt/fargate/) to reduce costs

---

Special thanks to [villasv/aws-airflow-stack](https://github.com/villasv/aws-airflow-stack), an incredible project, for the inspiration.

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin\_email | Admin email. Only If RBAC is enabled, this user will be created in the first run only. | string | `"admin@admin.com"` | no |
| admin\_lastname | Admin lastname. Only If RBAC is enabled, this user will be created in the first run only. | string | `"Doe"` | no |
| admin\_name | Admin name. Only If RBAC is enabled, this user will be created in the first run only. | string | `"John"` | no |
| admin\_password | Admin password. Only If RBAC is enabled. | string | `"false"` | no |
| admin\_username | Admin username used to authenticate. Only If RBAC is enabled, this user will be created in the first run only. | string | `"admin"` | no |
| ami | Default is `Ubuntu Server 18.04 LTS (HVM), SSD Volume Type.` | string | `"ami-0a313d6098716f372"` | no |
| aws\_region | AWS Region | string | `"us-east-1"` | no |
| azs | Run the EC2 Instances in these Availability Zones | map | `{ "1": "us-east-1a", "2": "us-east-1b", "3": "us-east-1c", "4": "us-east-1d" }` | no |
| cluster\_name | The name of the Airflow cluster (e.g. airflow-xyz). This variable is used to namespace all resources created by this module. | string | n/a | yes |
| cluster\_stage | The stage of the Airflow cluster (e.g. prod). | string | `"dev"` | no |
| custom\_env | Path to custom airflow environments variables. | string | `""` | no |
| custom\_requirements | Path to custom requirements.txt. | string | `""` | no |
| db\_allocated\_storage | Dabatase disk size. | string | `"20"` | no |
| db\_dbname | PostgreSQL database name. | string | `"airflow"` | no |
| db\_instance\_type | Instance type for PostgreSQL database | string | `"db.t2.micro"` | no |
| db\_password | PostgreSQL password. | string | n/a | yes |
| db\_subnet\_group\_name | db subnet group, if assigned, db will create in that subnet, default create in default vpc | string | `""` | no |
| db\_username | PostgreSQL username. | string | `"airflow"` | no |
| fernet\_key | Key for encrypting data in the database - see Airflow docs. | string | n/a | yes |
| instance\_subnet\_id | subnet id used for ec2 instances running airflow, if not defined, vpc's first element in subnetlist will be used | string | `""` | no |
| key\_name | AWS KeyPair name. | string | n/a | yes |
| load\_default\_conns | Load the default connections initialized by Airflow. Most consider these unnecessary, which is why the default is to not load them. | string | `"false"` | no |
| load\_example\_dags | Load the example DAGs distributed with Airflow. Useful if deploying a stack for demonstrating a few topologies, operators and scheduling strategies. | string | `"false"` | no |
| private\_key\_path | Enter the path to the SSH Private Key to run provisioner. | string | `"~/.ssh/id_rsa"` | no |
| public\_key\_path | Enter the path to the SSH Public Key to add to AWS. | string | `"~/.ssh/id_rsa.pub"` | no |
| rbac | Enable support for Role-Based Access Control (RBAC). | string | `"false"` | no |
| root\_volume\_delete\_on\_termination | Whether the volume should be destroyed on instance termination. | string | `"true"` | no |
| root\_volume\_ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized. | string | `"false"` | no |
| root\_volume\_size | The size, in GB, of the root EBS volume. | string | `"35"` | no |
| root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | string | `"standard"` | no |
| s3\_bucket\_name | S3 Bucket to save airflow logs. | string | `""` | no |
| scheduler\_instance\_type | Instance type for the Airflow Scheduler. | string | `"t3.micro"` | no |
| spot\_price | The maximum hourly price to pay for EC2 Spot Instances. | string | `""` | no |
| tags | Additional tags used into terraform-terraform-labels module. | map | n/a | yes |
| vpc\_id | The ID of the VPC in which the nodes will be deployed.  Uses default VPC if not supplied. | string | `""` | no |
| webserver\_instance\_type | Instance type for the Airflow Webserver. | string | `"t3.micro"` | no |
| webserver\_port | The port Airflow webserver will be listening. Ports below 1024 can be opened only with root privileges and the airflow process does not run as such. | string | `"8080"` | no |
| worker\_instance\_count | Number of worker instances to create. | string | `"1"` | no |
| worker\_instance\_type | Instance type for the Celery Worker. | string | `"t3.small"` | no |

## Outputs

| Name | Description |
|------|-------------|
| database\_endpoint | Endpoint to connect to RDS metadata DB |
| database\_username | Username to connect to RDS metadata DB |
| this\_cluster\_security\_group\_id | The ID of the security group |
| this\_database\_security\_group\_id | The ID of the security group |
| webserver\_admin\_url | Url for the Airflow Webserver Admin |
| webserver\_public\_ip | Public IP address for the Airflow Webserver instance |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

---
[![forthebadge](https://forthebadge.com/images/badges/powered-by-netflix.svg)](https://forthebadge.com) [![forthebadge](https://forthebadge.com/images/badges/contains-cat-gifs.svg)](https://forthebadge.com) [![forthebadge](https://forthebadge.com/images/badges/60-percent-of-the-time-works-every-time.svg)](https://forthebadge.com)
