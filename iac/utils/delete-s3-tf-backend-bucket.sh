#! /bin/bash
set -e

AWS_PROFILE="dev"
AWS_ACCOUNT="personal"
AWS_REGION="eu-west-2"
AWS_BUCKET="infra-euw2"
echo ""
echo "Deleting state store bucket of terraform..."
echo ""
echo "aws account: ${AWS_ACCOUNT}"
echo "aws profile: ${AWS_PROFILE}"
echo "aws region: ${AWS_REGION}"
echo "aws s3 bucket name: ${AWS_BUCKET}"

# Delete objects inside state-store bucket 
# NOTE: try force remove first, if fails, then remove objects first 
# and retry force removing.

aws s3api delete-objects --bucket $AWS_BUCKET --delete "$(aws s3api list-object-versions --bucket infra-euw2 --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')" > /dev/null

# Force remove bucket 
aws s3 rb s3://$AWS_BUCKET --force


echo "Finished cleaning up backend of terrform state store"
echo ""
exit 1


