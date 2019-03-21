## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami | Ubuntu 18.04 AMI. | string | `"ami-0a313d6098716f372"` | no |
| associate\_public\_ip\_address | If set to true, associate a public IP address with each EC2 Instance in the cluster. | string | `"false"` | no |
| aws\_key\_name | AWS KeyPair name | string | n/a | yes |
| aws\_region | AWS Region | string | `"us-east-1"` | no |
| cluster\_name | The name of the Airflow cluster (e.g. airflow-xyz). This variable is used to namespace all resources created by this module. | string | n/a | yes |
| cluster\_stage | The stage of the Airflow cluster (e.g. prod). | string | `"dev"` | no |
| db\_allocated\_storage | Dabatase disk size. | string | `"20"` | no |
| db\_dbname | PostgreSQL database name. | string | `"airflow"` | no |
| db\_instance\_type | Instance type for PostgreSQL database | string | `"db.t2.micro"` | no |
| db\_password | PostgreSQL password. | string | n/a | yes |
| db\_username | PostgreSQL username. | string | `"airflow"` | no |
| private\_key\_path | Enter the path to the SSH Private Key to run provisioner. | string | `"~/.ssh/id_rsa"` | no |
| public\_key\_path | Enter the path to the SSH Public Key to add to AWS. | string | `"~/.ssh/id_rsa.pub"` | no |
| root\_volume\_delete\_on\_termination | Whether the volume should be destroyed on instance termination. | string | `"true"` | no |
| root\_volume\_ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized. | string | `"false"` | no |
| root\_volume\_size | The size, in GB, of the root EBS volume. | string | `"30"` | no |
| root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | string | `"standard"` | no |
| s3\_bucket\_name |  | string | `""` | no |
| scheduler\_instance\_type | Instance type for the Airflow Scheduler | string | `"t3.small"` | no |
| spot\_price | The maximum hourly price to pay for EC2 Spot Instances. | string | `""` | no |
| vpc\_id | The ID of the VPC in which the nodes will be deployed.  Uses default VPC if not supplied. | string | `""` | no |
| webserver\_instance\_type | Instance type for the Airflow Webserver | string | `"t3.small"` | no |

## Outputs

| Name | Description |
|------|-------------|
| airflow\_instance\_public\_dns | Public DNS for the Airflow instance |
| airflow\_instance\_public\_ip | Public IP address for the Airflow instance |

