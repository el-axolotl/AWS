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

variable "user1" {
  description = "The IAM username for the infra engineer."
  type        = string
}

variable "user2" {
  description = "The IAM username for the dev."
  type        = string
}
