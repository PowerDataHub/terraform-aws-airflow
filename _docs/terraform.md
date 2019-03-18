## Required Inputs

The following input variables are required:

### aws\_key\_name

Description: SSH KeyPair

Type: `string`

### cluster\_name

Description: The name of the Airflow cluster (e.g. airflow-xyz). This variable is used to namespace all resources created by this module.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### ami

Description: Ubuntu 18.04 AMI code for the Airflow servers

Type: `string`

Default: `"ami-0a313d6098716f372"`

### associate\_public\_ip\_address

Description: If set to true, associate a public IP address with each EC2 Instance in the cluster.

Type: `string`

Default: `"false"`

### aws\_region

Description: AWS Region

Type: `string`

Default: `"us-east-1"`

### cluster\_stage

Description: The stage of the Airflow cluster (e.g. prod).

Type: `string`

Default: `"dev"`

### disk\_size

Description:

Type: `string`

Default: `"15"`

### root\_volume\_delete\_on\_termination

Description: Whether the volume should be destroyed on instance termination.

Type: `string`

Default: `"true"`

### root\_volume\_ebs\_optimized

Description: If true, the launched EC2 instance will be EBS-optimized.

Type: `string`

Default: `"false"`

### root\_volume\_size

Description: The size, in GB, of the root EBS volume.

Type: `string`

Default: `"50"`

### root\_volume\_type

Description: The type of volume. Must be one of: standard, gp2, or io1.

Type: `string`

Default: `"standard"`

### s3\_bucket\_name

Description:

Type: `string`

Default: `""`

### scheduler\_instance\_type

Description: Instance type for the Airflow Scheduler

Type: `string`

Default: `"t3.micro"`

### spot\_price

Description: The maximum hourly price to pay for EC2 Spot Instances.

Type: `string`

Default: `""`

### vpc\_id

Description: The ID of the VPC in which the nodes will be deployed.  Uses default VPC if not supplied.

Type: `string`

Default: `""`

### webserver\_instance\_type

Description: Instance type for the Airflow Webserver

Type: `string`

Default: `"t3.micro"`

## Outputs

The following outputs are exported:

### airflow\_instance\_public\_dns

Description: Public DNS for the Airflow instance

### airflow\_instance\_public\_ip

Description: Public IP address for the Airflow instance

