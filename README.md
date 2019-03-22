[![Maintained by Powerdatahub.com](https://img.shields.io/badge/maintained%20by-powerdatahub.com-%235849a6.svg)](https://powerdatahub.com/?ref=repo_aws_airflow)

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
}
```

### Todo

- [ ] Run airflow as systemd service
- [ ] Auto Scalling for workers
- [ ] Use SPOT instances for workers
- [ ] Maybe use the [AWS Fargate](https://aws.amazon.com/pt/fargate/) to reduce costs
- [ ] Provide a way to users pass a custom requirements.txt and packages.txt files


---

Special thanks to [villasv/aws-airflow-stack](https://github.com/villasv/aws-airflow-stack), an incredible project, for the inspiration.

---
