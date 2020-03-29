variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}
variable "aws_region" {}
variable "env" {
  description = "Name of environment being deployed into"
}
variable "db_password" {
  description = "Password to use for the Prestashop database."
}
