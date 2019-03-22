[![Maintained by Powerdatahub.com](https://img.shields.io/badge/maintained%20by-powerdatahub.com-%235849a6.svg)](https://powerdatahub.com/?ref=repo_aws_airflow) [![Apache Airflow 1.10.2](https://img.shields.io/badge/Apache%20Airflow-1.10.2-5849a6.svg)](https://github.com/apache/airflow/)

> WIP: NOT READY FOR PRODUCTION YET

# Airflow AWS Module

Terraform module to deploy an [Apache Airflow](https://airflow.apache.org/) instance on [AWS](https://aws.amazon.com/) backed by RDS PostgreSQL for storage, S3 for logs and SQS as message broker with CeleryExecutor.

## Getting started

You can use this module from the [Terraform Registry](https://registry.terraform.io/modules/powerdatahub/airflow/aws/)

```terraform
module "airflow-cluster" {
  source            = "powerdatahub/airflow/aws"
  cluster_name      = "my-airflow"
  cluster_stage     = "dev"
  db_password       = "rds-master-password"
  fernet_key        = "your-fernet-key"
  vpc_id            = "some-vpc-id"  
  aws_key_name      = "airflow-key"
  requirements-txt  = "./requirements.txt" # Optional
}
```

### Todo

- [ ] Run airflow as systemd service
- [ ] Auto Scalling for workers
- [ ] Use SPOT instances for workers
- [ ] Maybe use the [AWS Fargate](https://aws.amazon.com/pt/fargate/) to reduce costs
- [x] Provide a way to users pass a custom requirements.txt and packages.txt files

---

Special thanks to [villasv/aws-airflow-stack](https://github.com/villasv/aws-airflow-stack), an incredible project, for the inspiration.

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami | Default is: Ubuntu Server 18.04 LTS (HVM), SSD Volume Type. | string | `"ami-0a313d6098716f372"` | no |
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
| private\_key\_path | Enter the path to the SSH Private Key to run provisioner. | string | `"~/.ssh/id_rsa"` | no |
| public\_key\_path | Enter the path to the SSH Public Key to add to AWS. | string | `"~/.ssh/id_rsa.pub"` | no |
| requirements-txt | Custom requirements.txt | string | `""` | no |
| root\_volume\_delete\_on\_termination | Whether the volume should be destroyed on instance termination. | string | `"true"` | no |
| root\_volume\_ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized. | string | `"false"` | no |
| root\_volume\_size | The size, in GB, of the root EBS volume. | string | `"35"` | no |
| root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | string | `"standard"` | no |
| s3\_bucket\_name |  | string | `""` | no |
| scheduler\_instance\_type | Instance type for the Airflow Scheduler | string | `"t3.micro"` | no |
| spot\_price | The maximum hourly price to pay for EC2 Spot Instances. | string | `""` | no |
| vpc\_id | The ID of the VPC in which the nodes will be deployed.  Uses default VPC if not supplied. | string | `""` | no |
| webserver\_instance\_type | Instance type for the Airflow Webserver | string | `"t3.micro"` | no |
| worker\_instance\_type | Instance type for the Celery Worker | string | `"t3.small"` | no |

## Outputs

| Name | Description |
|------|-------------|
| airflow\_database\_endpoint | Endpoint to connect to RDS metadata DB |
| airflow\_database\_username | Username to connect to RDS metadata DB |
| airflow\_webserver\_public\_dns | Public DNS for the Airflow Webserver instance |
| airflow\_webserver\_public\_ip | Public IP address for the Airflow Webserver instance |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
