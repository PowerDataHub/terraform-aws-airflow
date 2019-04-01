# How to create a basic cluster and deploy some DAGs


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

## Deploy

After running `terraform apply` waiting for some minutes to server be provisioned and then run:

```bash
ansible-playbook --inventory-file=/usr/local/bin/terraform-inventory --ssh-common-args='-o StrictHostKeyChecking=no' -u ubuntu ansible/deploy_dags.yml
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
