# audit_wheel_users
#
# Check users in wheel group have recently logged in, if not lock them
#

audit_wheel_users () {
  if [ "$os_name" = "SunOS" ] || [ "$os_name" = "Linux" ] || [ "$os_name" = "Darwin" ]; then
    funct_verbose_message "Wheel Users"
    check_file="/etc/group"
    if [ "$audit_mode" != 2 ]; then
      for user_name in `cat $check_file |grep '^$wheel_group:' |cut -f4 -d: |sed 's/,/ /g'`; do
        last_login=`last -1 $user_name |grep '[a-z]' |awk '{print $1}'`
        if [ "$last_login" = "wtmp" ]; then
          total=`expr $total + 1`
          lock_test=`cat /etc/shadow |grep '^$user_name:' |grep -v 'LK' |cut -f1 -d:`
          if [ "$lock_test" = "$user_name" ]; then
            if [ "$audit_mode" = 1 ]; then
              insecure=`expr $insecure + 1`
              echo "Warning:   User $user_name has not logged in recently and their account is not locked [$insecure Warnings]"
            fi
            if [ "$audit_mode" = 0 ]; then
              funct_backup_file $check_file
              echo "Setting:   User $user_name to locked"
              passwd -l $user_name
            fi
          fi
        fi
      done
    else
      funct_restore_file $check_file $restore_dir
    fi
  fi
}
