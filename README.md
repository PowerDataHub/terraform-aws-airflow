[![Maintained by Powerdatahub.com](https://img.shields.io/badge/maintained%20by-powerdatahub.com-%235849a6.svg?style=for-the-badge)](https://powerdatahub.com/?ref=repo_aws_airflow) [![Apache Airflow 1.10.2](https://img.shields.io/badge/Apache%20Airflow-1.10.2-5849a6.svg?style=for-the-badge)](https://github.com/apache/airflow/)

# Airflow AWS Module

Terraform module to deploy an [Apache Airflow](https://airflow.apache.org/) instance on [AWS](https://aws.amazon.com/) backed by RDS PostgreSQL for storage, S3 for logs and SQS as message broker with CeleryExecutor.


<img src="https://raw.githubusercontent.com/PowerDataHub/terraform-aws-airflow/master/terraform-aws-airflow.png?raw" align="center" width="100%" />

## Usage

You can use this module from the [Terraform Registry](https://registry.terraform.io/modules/powerdatahub/airflow/aws/)

```terraform
module "airflow-cluster" {
  source            = "powerdatahub/airflow/aws"
  aws_key_name      = "airflow-key"
  cluster_name      = "my-airflow"
  cluster_stage     = "dev"
  db_password       = "your-rds-master-password"
  fernet_key        = "your-fernet-key" # see https://airflow.readthedocs.io/en/stable/howto/secure-connections.html
  vpc_id            = "some-vpc-id" # Optional, use default if not provided  
  requirements_txt  = "path/to/custom/requirements.txt" # Optional
  load_example_dags = false # Optional
}
```

## Debug and logs

The Airflow service runs under systemd, so logs are available through journalctl.

`$ journalctl -u airflow -n 50`

## Todo

- [x] Run airflow as systemd service
- [x] Provide a way to pass a custom requirements.txt files on provision step
- [ ] Provide a way to pass a custom packages.txt files on provision step
- [ ] RBAC
- [ ] Flower
- [ ] Provide a way inject envinronment variables to airflow
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
| ami | Default is `Ubuntu Server 18.04 LTS (HVM), SSD Volume Type.` | string | `"ami-0a313d6098716f372"` | no |
| aws\_key\_name | AWS KeyPair name | string | n/a | yes |
| aws\_region | AWS Region | string | `"us-east-1"` | no |
| cluster\_name | The name of the Airflow cluster (e.g. airflow-xyz). This variable is used to namespace all resources created by this module. | string | n/a | yes |
| cluster\_stage | The stage of the Airflow cluster (e.g. prod). | string | `"dev"` | no |
| db\_allocated\_storage | Dabatase disk size. | string | `"20"` | no |
| db\_dbname | PostgreSQL database name. | string | `"airflow"` | no |
| db\_instance\_type | Instance type for PostgreSQL database | string | `"db.t2.micro"` | no |
| db\_password | PostgreSQL password. | string | n/a | yes |
| db\_username | PostgreSQL username. | string | `"airflow"` | no |
| fernet\_key | Key for encrypting data in the database - see Airflow docs | string | n/a | yes |
| load\_default\_conns | Load the default connections initialized by Airflow. Most consider these unnecessary, which is why the default is to not load them. | string | `"false"` | no |
| load\_example\_dags | Load the example DAGs distributed with Airflow. Useful if deploying a stack for demonstrating a few topologies, operators and scheduling strategies. | string | `"false"` | no |
| private\_key\_path | Enter the path to the SSH Private Key to run provisioner. | string | `"~/.ssh/id_rsa"` | no |
| public\_key\_path | Enter the path to the SSH Public Key to add to AWS. | string | `"~/.ssh/id_rsa.pub"` | no |
| requirements\_txt | Custom requirements.txt | string | `""` | no |
| root\_volume\_delete\_on\_termination | Whether the volume should be destroyed on instance termination. | string | `"true"` | no |
| root\_volume\_ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized. | string | `"false"` | no |
| root\_volume\_size | The size, in GB, of the root EBS volume. | string | `"35"` | no |
| root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | string | `"standard"` | no |
| s3\_bucket\_name | S3 Bucket to save airflow logs. | string | `""` | no |
| scheduler\_instance\_type | Instance type for the Airflow Scheduler | string | `"t3.micro"` | no |
| spot\_price | The maximum hourly price to pay for EC2 Spot Instances. | string | `""` | no |
| vpc\_id | The ID of the VPC in which the nodes will be deployed.  Uses default VPC if not supplied. | string | `""` | no |
| webserver\_instance\_type | Instance type for the Airflow Webserver | string | `"t3.micro"` | no |
| worker\_instance\_type | Instance type for the Celery Worker | string | `"t3.small"` | no |

## Outputs

| Name | Description |
|------|-------------|
| database\_endpoint | Endpoint to connect to RDS metadata DB |
| database\_username | Username to connect to RDS metadata DB |
| this\_cluster\_security\_group\_id | The ID of the security group |
| this\_database\_security\_group\_id | The ID of the security group |
| webserver\_admin\_url | Public DNS for the Airflow Webserver instance |
| webserver\_public\_ip | Public IP address for the Airflow Webserver instance |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

---

[![forthebadge](https://forthebadge.com/images/badges/made-with-python.svg)](https://forthebadge.com) [![forthebadge](https://forthebadge.com/images/badges/winter-is-coming.svg)](https://forthebadge.com) [![forthebadge](https://forthebadge.com/images/badges/contains-cat-gifs.svg)](https://forthebadge.com) [![Open Source Love](https://badges.frapsoft.com/os/v2/open-source-200x33.png?v=103)](https://github.com/ellerbrock/open-source-badges/)
