# audit_kernel_modules
#
# Refer to http://kb.vmware.com/kb/2042473.
#.

audit_kernel_modules () {
  if [ "$os_name" = "VMkernel" ]; then
    funct_verbose_message "Kernel Module Signing"
    for module in `esxcli system module list |grep '^[a-z]' |awk '($3 == "true") {print $1}'`; do
      total=`expr $total + 1`
      log_file="kernel_module_$module"
      backup_file="$work_dir/$log_file"
      current_value=`esxcli system module get -m $module |grep 'Signed Status' |awk -F': ' '{print $2}'`
      if [ "$audit_mode" != "2" ]; then
        if [ "$current_value" != "VMware Signed" ]; then
          if [ "$audit_more" = "0" ]; then
            if [ "$syslog_server" != "" ]; then
              echo "Setting:   Kernel module $module to disabled"
              echo "true" > $backup_file
              esxcli system module set -e false -m $module
            fi
          fi
          if [ "$audit_mode" = "1" ]; then
            insecure=`expr $insecure + 1`
            echo "Warning:   Kernel module $module is not signed by VMware [$insecure Warnings]"
            funct_verbose_message "" fix
            funct_verbose_message "esxcli system module set -e false -m $module" fix
          fi
        else
          if [ "$audit_mode" = "1" ]; then
            secure=`expr $secure + 1`
            echo "Secure:    Kernel module $module is signed by VMware [$secure Passes]"
          fi
        fi
      else
        restore_file="$restore_dir/$log_file"
        if [ -f "$restore_file" ]; then
          previous_value=`cat $restore_file`
          if [ "$previous_value" != "$current_value" ]; then
            echo "Restoring: Kernel module to $previous_value"
            esxcli system module set -e $previous_value -m $module
          fi
        fi
      fi
    done
  fi
}
