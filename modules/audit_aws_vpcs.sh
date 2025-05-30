#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_aws_vpcs
#
# Check VPCs
#
# Refer to Section(s) 4.2 Page(s) 133-4  CIS AWS Foundations Benchmark v1.1.0
# Refer to Section(s) 4.3 Page(s) 135-7  CIS AWS Foundations Benchmark v1.1.0
# Refer to Section(s) 4.4 Page(s) 138-40 CIS AWS Foundations Benchmark v1.1.0
# Refer to Section(s) 4.5 Page(s) 141-2  CIS AWS Foundations Benchmark v1.1.0
#
# Refer http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/SettingLogRetention.html
# Refer to https://www.cloudconformity.com/conformity-rules/VPC/endpoint-exposed.html
#.

audit_aws_vpcs () {
  print_function    "audit_aws_vpcs"
  verbose_message "VPCs"   "check"
  # Check for exposed VPC endpoints
  endpoint_list=$( aws ec2 describe-vpc-endpoints --region "${aws_region}" --query 'VpcEndpoints[*].VpcEndpointId' --output text )
  for endpoint in ${endpoint_list}; do
    vpc=$( aws ec2 describe-vpc-endpoints --region "${aws_region}" --vpc-endpoint-ids "$endpoint" --query 'VpcEndpoints[].PolicyDocument' |grep Principal |grep -E "\*|{\"AWS\":\"\*\"}" )
    if [ -n "${vpc}" ]; then
      increment_insecure    "VPC \"${vpc}\" has en exposed enpoint"
    else
      increment_secure      "VPC \"${vpc}\" does not have an exposed endpoint"
    fi
  done
  # Check for VPC peering
	vpc_peers=$( aws ec2 describe-vpc-peering-connections --region "${aws_region}" --query VpcPeeringConnections --output text )
  if [ -z "${vpc_peers}" ]; then
    increment_secure "VPC peering is not being used"
  else
    vpcs=$( aws ec2 describe-vpcs --query Vpcs[].VpcId --output text )
    for vpc in ${vpcs}; do
      check=$( aws ec2 describe-route-tables --region "${aws_region}" --filter "Name=vpc-id,Values=${vpc}" --query "RouteTables[*].{RouteTableId:RouteTableId, VpcId:VpcId, Routes:Routes,AssociatedSubnets:Associations[*].SubnetId}" | grep GatewayID | grep pcx- )
      if [ -z "${check}" ]; then
        increment_secure    "VPC \"${vpc}\" does not have a peer as it's gateway"
      else
        increment_insecure  "VPC peering is being used review VPC: \"${vpc}\""
        verbose_message     "aws ec2 delete-route --region ${aws_region} --route-table-id <route_table_id> --destination-cidr-block <non_compliant_destination_CIDR>" "fix"
        verbose_message     "aws ec2 create-route --region ${aws_region} --route-table-id <route_table_id> --destination-cidr-block <compliant_destination_CIDR> --vpc-peering-connection-id <peering_connection_id>" "fix"
      fi
    done
  fi
  # Check for VPC flow logging
  logs=$( aws ec2 describe-flow-logs --region "${aws_region}" --query FlowLogs[].FlowLogId --output text )
  if [ -n "${logs}" ]; then
    vpcs=$( aws ec2 describe-vpcs --region "${aws_region}" --query Vpcs[].VpcId --output text )
    for vpc in ${vpcs}; do
      vpc_check=$( aws ec2 describe-flow-logs --region "${aws_region}" --query FlowLogs[].ResourceId --output text )
      if [ "${vpc_check}" ]; then
        active_check=$( aws ec2 describe-flow-logs --region "${aws_region}" --filter "Name=resource-id,Values=${vpc}" | grep FlowLogStatus | grep ACTIVE )
        if [ -n "${active_check}" ]; then
          increment_secure    "VPC \"${vpc}\" has active flow logs"
        else
          increment_insecure  "VPC \"${vpc}\" has flow logs but they are not active"
        fi
      else
        increment_insecure    "VPC \"${vpc}\" does not have flow logs"
      fi
    done
  else
    increment_insecure "There are no VPC flow logs"
  fi
}

