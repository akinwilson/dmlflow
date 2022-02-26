#!/bin/bash
set -e

AWS_PROFILE="akinwilson"
AWS_REGION="eu-west-2"
AWS_BUCKET="infra-euw2"

echo "Creating backend s3 bucket for terraform version control.."
echo "This bucket will track the version of infrastructure deployed"
echo "aws account: ${AWS_PROFILE}"
echo "aws region: ${AWS_REGION}"
echo "aws s3 bucket name: ${AWS_BUCKET}"

aws s3api create-bucket \
--bucket $AWS_BUCKET \
--acl private \
--region $AWS_REGION \
--create-bucket-configuration '{"LocationConstraint":"'"$AWS_REGION"'"}' \
--profile $AWS_PROFILE >/dev/null 

aws s3api put-bucket-tagging \
--bucket $AWS_BUCKET \
--tagging 'TagSet=[{Key=purpose,Value=tf-store}]' \
--profile $AWS_PROFILE >/dev/null

aws s3api put-bucket-versioning \
--bucket $AWS_BUCKET \
--versioning-configuration Status=Enabled \
--profile $AWS_PROFILE >/dev/null

exit 1