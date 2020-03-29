# production-ready-prestashop
 [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
 
Deploy a Scalable, highly available, and performant Prestashop solution on AWS using CloudFormation


![Scalable Prestashop Architecture Diagram](https://github.com/Zir0-93/zir0-93.github.io/blob/master/images/scalable_presta.png?raw=true)

# Getting Started
The deployment consists of various CloudFormation templates that are deployed and teared down using the [Terraform Provider for AWS](https://github.com/terraform-providers/terraform-provider-aws):
  * `private-vpc.yaml`: Deploys containerized applications onto a cluster of EC2 hosts using Elastic Container Service. This stack runs containers on   hosts that are in a private VPC subnet. Outbound network traffic from the
  hosts must go out through a NAT gateway.
  * `efs-service.yaml`: Deploys an EFS file system with the appropriate folder mounts required for Prestashop ECS Containers.
  * `rds-service.yaml`: Deploys an RDS MariaDB instance that Prestashop will use. Multi-AZ is disabled by default.
  * `ec2-service.yaml`: Deploys an EC2 AutoScaling Groups, Public Load balancer, and Security Groups required for the entire deployment.
  * `ecs-service.yaml`: Deploys an elastic container service that will run Prestashop containers on registered instances in our cluster.
  * `service-autoscaling.yaml`: A stack for configuring autoscaling between the EC2 ASG and ECS Service using CloudWatch alarms.
  
### Deploy
1. Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
2. From the root directory
    1. Execute `terraform init`
    2. Execute `terraform apply -v 'aws_access_key=<aws_access_key>'
                                   -v 'aws_secret_key=<aws_secret_key>'
                                   -v 'aws_account_id=<aws_account_id>'
                                   -v 'db_password=<database_password>'
                                   -v 'aws_region=<aws_region'
                                   -v 'env=<environment>'`
        * **Note**: `db_password` corresponds to the password of the database used for the Prestashop deployment. 
### Teardown
 1. Execute `terraform destroy`
 
 # Contributors
 * [Muntazir Fadhel](www.fadhelsolutions.com)
