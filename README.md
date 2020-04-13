# production-ready-prestashop
 [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
 
Deploy a Scalable, highly available, and performant Prestashop solution on AWS using CloudFormation.
![https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png](https://console.aws.amazon.com/cloudformation/home?region=ca-central-1#/stacks/new?stackName=prestashop-stack&templateURL=https://production-ready-prestashop.s3.ca-central-1.amazonaws.com/versions/latest/production_ready_prestashop.yaml)

![Scalable Prestashop Architecture Diagram](https://github.com/Zir0-93/zir0-93.github.io/blob/master/images/scalable_presta.png?raw=true)

# Getting Started
The entire solution is represented using multiple CloudFormation stacks:
  * `production_ready_prestashop.yaml`: The parent CloudFormation stack that deploys all the major infrastructure components below that comprise the entire solutions as nested CloudFormation stacks.
  * `private-vpc.yaml`: Deploys containerized applications onto a cluster of EC2 hosts using Elastic Container Service. This stack runs containers on hosts that are in a private VPC subnet. Outbound network traffic from the hosts must go out through a NAT gateway.
  * `efs-service.yaml`: Deploys an EFS file system with the appropriate folder mounts required for Prestashop ECS Containers.
  * `rds-service.yaml`: Deploys an RDS MariaDB instance that Prestashop will use. Multi-AZ is disabled by default.
  * `ec2-service.yaml`: Deploys an EC2 AutoScaling Groups, Public Load balancer, and Security Groups required for the entire deployment.
  * `ecs-service.yaml`: Deploys an elastic container service that will run Prestashop containers on registered instances in our cluster.
  * `service-autoscaling.yaml`: A stack for configuring autoscaling between the EC2 ASG and ECS Service using CloudWatch alarms.
  
### Development Environment
1. Setup an AWS account.
2. Install [taskcat](https://github.com/aws-quickstart/taskcat)
3. Install the [AWS cli tool](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
   
#### Local Testing
1. Push your templates to an S3 bucket: `aws s3 sync --acl public-read templates/ s3://your-bucket`
2. Update the `NestedStacksS3URL` param in taskcat's config file (`.taskcat.yml`) to point to the S3 URL containing your template files ([example](https://production-ready-prestashop.s3.ca-central-1.amazonaws.com/versions/latest))
3. Run `taskcat -d test run`

### Contribute
Refer to `.github/workflows/ci-cd.yml` to get an idea of what the CI pipeline does to test pull requests. Fork this repository, open a pull request, ensure all checks pass, ensure `taskcat` is not throwing any lint warnings, and request a review.
 
 ### Important Implementation Notes
* The ECS cloudformation template launches containers with an environment variable `PS_ERASE_DB` set to `1`. This will erase the prestashop database every time a new container is started. This is required to setup the database the first time. Once this is done, run `aws cloudformation update-stack` with a value of `0`.
* The RDS cloudformation template does not enable multi-AZ by default. This can easily be modified by setting `Properties.MultiAZ` to `true` for the `AWS::RDS::DBInstance` resource in this stack.


 # Contributors
 * [Muntazir Fadhel](www.fadhelsolutions.com)
