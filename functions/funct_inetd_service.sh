# funct_inetd_service
#
# Change status of an inetd (/etc/inetd.conf) services
#
#.

funct_inetd_service () {
  if [ "$os_name" = "Linux" ] || [ "$os_name" = "SunOS" ]; then
    service_name=$1
    correct_status=$2
    check_file="/etc/inetd.conf"
    log_file="$service_name.log"
    if [ -f "$check_file" ]; then
      if [ "$correct_status" = "disabled" ]; then
        actual_status=`cat $check_file |grep '^$service_name' |grep -v '^#' |awk '{print $1}'`
      else
        actual_status=`cat $check_file |grep '^$service_name' |awk '{print $1}'`
      fi
      if [ "$audit_mode" != 2 ]; then
        echo "Checking:  If inetd service $service_name is set to $correct_status"
        total=`expr $total + 1`
        if [ "$actual_status" != "" ]; then
          if [ "$audit_mode" = 1 ]; then
            insecure=`expr $insecure + 1`
            echo "Warning:   Service $service_name does not have $parameter_name set to $correct_status [$insecure Warnings]"
          else
            if [ "$audit_mode" = 0 ]; then
              funct_backup_file $check_file
              if [ "$correct_status" = "disable" ]; then
                funct_disable_value $check_file $service_name hash
              else
                :
              fi
            fi
          fi
        else
          if [ "$audit_mode" = 1 ]; then
            secure=`expr $secure + 1`
            echo "Secure:    Service $service_name is set to $correct_status [$secure Passes]"
          fi
        fi
      else
        funct_restore_file $check_file $restore_dir
      fi
    fi
  fi
}
