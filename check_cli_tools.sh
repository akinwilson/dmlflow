#!/usr/bin/env bash

# Verify that appropriate tools are installed.
if [ -z "$(command -v docker)" ]; then
  echo "Unable to find Docker"
  echo "To install Docker, please follow this guide: https://docs.docker.com/get-docker"
  exit 1
fi


if [ -z "$(command -v aws)"]; then 
  echo "Unable to find AWS CLI"
  echo "To install AWS CLI, please follow this guide: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"


if [ -z "$(command -v terraform)" ]; then
  echo "Unable to find Terraform"
  echo "To install Terraform, please follow this guide: https://developer.hashicorp.com/terraform/install"
  exit 1
fi


echo "You have all CLI tools required, ready to remotely deploy an MLflow server to AWS"
