# funct_chuser_check
#
# Function to check sec under AIX
#.

funct_chuser_check() {
  if [ "$os_name" = "AIX" ]; then
    sec_file=$1
    parameter_name=$2
    correct_value=$3
    group_name=$4
    group_value=$5
    user_name=$6
    log_file="$sec_file_$parameter_name_$group_name.log"
    if [ "$audit_mode" != 2 ]; then
      echo "Checking:  Security Policy for \"$parameter_name\" is set to \"$correct_value\""
      actual_value=`lssec -f $sec_file -s $user_name -a $group_name -a $parameter_name |awk '{print $3}' |cut -f2 -d=`
      if [ "$actual_value" != "$correct_value" ]; then
        if [ "$audit_mode" = 1 ]; then
          total=`expr $total + 1`
          insecure=`expr $insecure + 1`
          echo "Warning:   Security Policy for \"$parameter_name\" is not set to \"$correct_value\" for \"$user_name\" [$insecure Warnings]"
          funct_verbose_message "" fix
          funct_verbose_message "chuser $parameter_name=$correct_value $group_name=$group_value $user_name" fix
          funct_verbose_message "" fix
        fi
        if [ "$audit_mode" = 0 ]; then
          log_file="$work_dir/$log_file"
          echo "Setting:   Security Policy for \"$parameter_name\" to \"$correct_value\""
          echo "chuser $parameter_name=$correct_value $group_name=$group_value $user_name" > $log_file
          chuser $parameter_name=$correct_value $group_name=$group_value $user_name
        fi
      else
        if [ "$audit_mode" = 1 ]; then
          total=`expr $total + 1`
          secure=`expr $secure + 1`
          echo "Secure:    Password Policy for \"$parameter_name\" is set to \"$correct_value\" for \"$user_name\" [$secure Passes]"
        fi
      fi
    else
      log_file="$restore_dir/$log_file"
      if [ -f "$log_file" ]; then
        previous_value=`cat $log_file |cut -f2 -d=`
        if [ "$previous_value" != "$actual_value" ]; then
          echo "Restoring: Password Policy for \"$parameter_name\" to \"$previous_value\""
          cat $log_file |sh
        fi
      fi
    fi
  fi
}
