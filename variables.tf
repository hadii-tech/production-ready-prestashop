variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}
variable "db_password" {}
variable "aws_region" {
  description = "AWS region e.g. us-east-1 (Please specify a region supported by the Fargate launch type)"
}
variable "env" {
  description = "Name of environment being deployed into"
}
