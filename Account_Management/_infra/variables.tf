locals {
  account_id = data.aws_caller_identity.current.account_id
}

variable "env" {
  description = "The environment to deploy all resources."

  type = string
}

variable "name" {
  description = "The name of the app."

  type    = string
  default = "account-management"
}

variable "region" {
  description = "The AWS region to deploy all resources."

  type    = string
  default = "us-west-2"
}

variable "repo" {
  description = "The repository where this code lives."

  type    = string
  default = "AWS"
}

variable "s3_force_destroy" {
  description = "Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error."

  type = string
  default = "false"
}
