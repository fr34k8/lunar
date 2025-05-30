#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_aws_s3
#
# Check AWS S3
#
# Refer to https://www.cloudconformity.com/conformity-rules/S3/s3-bucket-authenticated-users-full-control-access.html
# Refer to https://www.cloudconformity.com/conformity-rules/S3/s3-bucket-logging-enabled.html
# Refer to https://www.cloudconformity.com/conformity-rules/S3/s3-bucket-public-full-control-access.html
#.

audit_aws_s3 () {
  print_function  "audit_aws_s3"
  verbose_message "S3"   "check"
  buckets=$( aws s3api list-buckets --region "${aws_region}" --query 'Buckets[*].Name' --output text )
  for bucket in ${buckets}; do
    for user in http://acs.amazonaws.com/groups/global/AllUsers http://acs.amazonaws.com/groups/global/AuthenticatedUsers; do
      grants=$( aws s3api get-bucket-acl --region "${aws_region}" --bucket "${bucket}" | grep URI | grep "${user}" )
      if [ -n "${grants}" ]; then
        increment_insecure  "Bucket \"${bucket}\" grants access to Principal \"${user}\""
      else
        increment_secure    "Bucket \"${bucket}\" does not grant access to Principal \"${user}\""
      fi
    done
    check=$( aws s3api get-bucket-logging --region "${aws_region}" --bucket "${bucket}" )
    if [ -z "${check}" ]; then
      increment_insecure "Bucket ${bucket} does not have access logging enabled"
      verbose_message    "aws s3api put-bucket-acl --region ${aws_region} --bucket ${bucket} --grant-write URI=http://acs.amazonaws.com/groups/s3/LogDelivery --grant-read-acp URI=http://acs.amazonaws.com/groups/s3/LogDelivery" "fix"
      verbose_message    "cd aws ; aws s3api put-bucket-logging --region ${aws_region} --bucket ${bucket} --bucket-logging-status file://server-access-logging.json"
    else
      increment_secure   "Bucket \"${bucket}\" has access logging enabled"
    fi
    check=$( aws s3api get-bucket-versioning --bucket "${bucket}" | grep Enabled )
    if [ -n "${check}" ]; then
      increment_secure   "Bucket \"${bucket}\" has versioning enabled"
    else
      increment_insecure "Bucket \"${bucket}\" does not have versioning enabled"
    fi
  done
}

