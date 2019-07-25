# How to create a basic cluster with custom Tags

Configuration in this directory creates a airflow cluster including EC2 instances, DB instance, SQS queue and S3 bucket.


## Requirements

- Terraform
- Ansible
- [terraform-inventory](https://github.com/adammck/terraform-inventory)

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

**WARNING - Database passwords and Fernet Key are hardcoded in the sample configuration: do not use these in production**

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
