provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
  version = "2.46.0"
}

locals {
  # Prefix to apply to all resources spun up in AWS
  aws_resource_prefix = "${var.project}-${var.env}"
  # The name of the CloudFormation stack to be created for the VPC and related resources
  aws_vpc_stack_name = "${local.aws_resource_prefix}-vpc"
  # The name of the CloudFormation stack to be created for the EC2 service and related resources
  aws_ec2_stack_name = "${local.aws_resource_prefix}-ec2"
  # The name of the CloudFormation stack to be created for the ECS service and related resources
  aws_ecs_stack_name = "${local.aws_resource_prefix}-ecs"
  # The name of the CloudFormation stack to be created for autoscaling the service
  aws_autoscaling_stack_name = "${local.aws_resource_prefix}-autoscale"
  # The name of the CloudFormation stack to be created for the RDS service and related resources
  aws_rds_stack_name = "${local.aws_resource_prefix}-rds"
  # The name of the CloudFormation stack to be created for the EFS service and related resources
  aws_efs_stack_name = "${local.aws_resource_prefix}-efs"
  # ECS Cluster name
  ecs_cluster_name = "${local.aws_resource_prefix}-Cluster"
}

resource "aws_cloudformation_stack" "vpc" {
  name = "${local.aws_vpc_stack_name}"
  capabilities = ["CAPABILITY_IAM"]
  template_body = "${file("cloudformation-templates/private-vpc.yml")}"
}

resource "aws_cloudformation_stack" "rds" {
  name = "${local.aws_rds_stack_name}"
  template_body = "${file("cloudformation-templates/rds-service.yml")}"
  depends_on = [aws_cloudformation_stack.vpc]
  parameters = {
    DatabaseUsername = "root"
    AllocatedStorage = 10
    DatabasePassword = "${var.rds_db_password}"
    VPCStackName = "${local.aws_vpc_stack_name}"
    DatabaseName = "prestashop"
  }
}

resource "aws_cloudformation_stack" "efs" {
  name = "${local.aws_efs_stack_name}"
  template_body = "${file("cloudformation-templates/efs-service.yml")}"
  depends_on = [aws_cloudformation_stack.vpc]
  parameters = {
    VPCStackName = "${local.aws_vpc_stack_name}"
  }
}

resource "aws_cloudformation_stack" "ec2" {
  name = "${local.aws_ec2_stack_name}"
  capabilities = ["CAPABILITY_IAM"]
  template_body = "${file("cloudformation-templates/ec2-service.yml")}"
  depends_on = [aws_cloudformation_stack.rds, aws_cloudformation_stack.efs ]
  parameters = {
    MaxInstanceCount = 10
    DesiredInstanceCount = 1
    InstanceType = "t2.nano"
    ECSClusterName = "${local.ecs_cluster_name}"
    RDSStackName = "${local.aws_rds_stack_name}"
    VPCStackName = "${local.aws_vpc_stack_name}"
    EFSStackName = "${local.aws_efs_stack_name}"
  }
}

resource "aws_cloudformation_stack" "ecs" {
  name = "${local.aws_ecs_stack_name}"
  capabilities = ["CAPABILITY_IAM"]
  template_body = "${file("cloudformation-templates/ecs-service.yml")}"
  depends_on = [aws_cloudformation_stack.ec2]
  parameters = {
    ECSClusterName = "${local.ecs_cluster_name}"
    DesiredTaskCount = 1
    ImageUrl = "prestashop/prestashop:1.7-7.0"
    RDSStackName = "${local.aws_rds_stack_name}"
    VPCStackName = "${local.aws_vpc_stack_name}"
    EFSStackName = "${local.aws_efs_stack_name}"
    EC2StackName = "${local.aws_ec2_stack_name}"
  }
}

resource "aws_cloudformation_stack" "autoscale" {
  name = "${local.aws_autoscaling_stack_name}"
  template_body = "${file("cloudformation-templates/service-autoscaling.yml")}"
  depends_on = [aws_cloudformation_stack.ecs, aws_cloudformation_stack.ec2]
  parameters = {
    ECSStackName = "${local.aws_ecs_stack_name}"
    EC2StackName = "${local.aws_ec2_stack_name}"
    LowCPUThreshold = 30
    HighCPUThreshold = 60
    LowMemThreshold = 30
    HighMemThreshold = 60
  }
}
