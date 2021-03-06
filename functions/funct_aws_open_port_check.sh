# funct_aws_open_port_check
#
# Check AWS Security Groups for open ports, i.e. CIDR of 0.0.0.0/0
#
# This requires the AWS CLI to be installed and configured
#.

funct_aws_open_port_check () {
  sg=$1
	port=$2
  protocol=$3
	service=$4
  app=$5
  instance=$6
  total=`expr $total + 1`
  open_port=`aws ec2 describe-security-groups --region $aws_region --group-ids $sg --filters "Name=ip-permission.to-port,Values=$port" "Name=ip-permission.cidr,Values=0.0.0.0/0" "Name=ip-permission.protocol,Values=$protocol" --output text`
    if [ ! "$open_port" ]; then
      secure=`expr $secure + 1`
      if [ "$elb" = "none" ]; then
        echo "Secure:    Security Group $sg does not have $service on port $port open to the world [$secure Passes]"
      else
        echo "Secure:    ELB $elb with Security Group $sg does not have $service on port $port open to the world [$secure Passes]"
      fi
    else
      insecure=`expr $insecure + 1`
      if [ "$app" = "none" ]; then
        echo "Warning:   Security Group $sg has $service on port $port open to the world [$insecure Warnings]"
      else
        echo "Warning:   $app $instance with Security Group $sg has $service on port $port open to the world [$insecure Warnings]"
      fi
      funct_verbose_message "" fix
      funct_verbose_message "aws ec2 revoke-security-group-ingress --region $aws_region --group-name $sg --protocol $protocol --port $port --cidr 0.0.0.0/0" fix
      funct_verbose_message "" fix
    fi
}
