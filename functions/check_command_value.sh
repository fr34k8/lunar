#!/bin/sh

# shellcheck disable=SC2034
# shellcheck disable=SC1090
# shellcheck disable=SC2154

# check_command_value
#
# Audit command output values
#
# Depending on the command_name send an appropriate check_command and set_command are set
# If the current_value is not the correct_value then it is fixed if run in lockdown mode
# A copy of the value is stored in a log file, which can be restored
#.

check_command_value () {
  command_name="$1"
  parameter_name="$2"
  correct_value="$3"
  service_name="$4"
  if [ "$audit_mode" = 2 ]; then
    restore_file="$restore_dir/$command_name.log"
    if [ -f "$restore_file" ]; then
      parameter_name=$( grep "$parameter_name" "$restore_file" | cut -f1 -d',' )
      correct_value=$( grep "$parameter_name" "$restore_file" | cut -f2 -d',' )
      p_test=$( echo "$parameter_name" | grep "[A-z]" )
      if [ -n "$p_test" ]; then
        verbose_message "Returning \"$parameter_name\" to \"$correct_value\""
        if [ "$command_name" = "routeadm" ]; then
          if [ "$correct_value" = "disabled" ]; then
            set_command="routeadm -d"
          else
            set_command="routeadm -e"
          fi
          eval "$set_command $parameter_name"
        else
          eval "$set_command $parameter_name=$correct_value"
          p_test=$( echo "$parameter_name" | grep "tcp_trace" )
          if [ -n "$p_test" ]; then
            svcadm refresh svc:/network/inetd
          fi
        fi
      fi
    fi
  else
    if [ "$parameter_name" = "tcp_wrappers" ]; then
      string="Service \"$service_name\" has \"$parameter_name\" set to \"$correct_value\""
    else
      string="Output of command \"$command_name\" parameter \"$parameter_name\" is \"$correct_value\""
    fi
   verbose_message "$string" "check"
  fi
  if [ "$command_name" = "inetadm" ]; then
    check_command="inetadm -l $service_name"
    set_command="inetadm -m $service_name"
    current_value=$( $check_command | grep "$parameter_name" | awk '{print $2}' | cut -f2 -d'=' )
  fi
  if [ "$command_name" = "routeadm" ]; then
    check_command="routeadm -p $parameter_name"
    current_value=$( $check_command | awk '{print $3}' | cut -f2 -d'=' )
    if [ "$correct_value" = "disabled" ]; then
      set_command="routeadm -d"
    else
      set_command="routeadm -e"
    fi
    l_command="$set_command $parameter_name"
  else
    l_command="$set_command $parameter_name=$correct_value"
  fi
  if [ "$ansible" = 1 ]; then
    echo ""
    echo "- name: Checking $string"
    echo "  command: sh -c \"$check_command\""
    echo "  register: lssec_check"
    echo "  failed_when: lssec_check == 1"
    echo "  changed_when: false"
    echo "  ignore_errors: true"
    echo "  when: ansible_facts['ansible_system'] == '$os_name'"
    echo ""
    echo "- name: Fixing $string"
    echo "  command: sh -c \"$l_command\""
    echo "  when: lssec_check.rc == 1 and ansible_facts['ansible_system'] == '$os_name'"
    echo ""
  fi
  log_file="$work_dir/$command_name.log"
  if [ "$current_value" != "$correct_value" ]; then
    if [ "$audit_mode" = 1 ]; then
      increment_insecure "Parameter \"$parameter_name\" not set to \"$correct_value\""
      if [ "$command_name" = "routeadm" ]; then
        if [ "$correct_value" = "disabled" ]; then
          set_command="routeadm -d"
        else
          set_command="routeadm -e"
        fi
        verbose_message "$set_command $parameter_name" "fix"
      else
        verbose_message "$set_command $parameter_name=$correct_value" "fix"
      fi
    else
      if [ "$audit_mode" = 0 ]; then
        verbose_message "Setting:   $parameter_name to $correct_value"
        echo "$parameter_name,$current_value" >> "$log_file"
        if [ "$command_name" = "routeadm" ]; then
          if [ "$correct_value" = "disabled" ]; then
            set_command="routeadm -d"
          else
            set_command="routeadm -e"
          fi
          eval "$set_command $parameter_name"
        else
          eval "$set_command $parameter_name=$correct_value"
        fi 
      fi
    fi
  else
    if [ "$audit_mode" != 2 ]; then
      if [ "$audit_mode" = 1 ]; then
        if [ "$parameter_name" = "tcp_wrappers" ]; then
          increment_secure "Service \"$service_name\" already has \"$parameter_name\" set to \"$correct_value\""
        else
          increment_secure "Output for command \"$command_name\" parameter \"$parameter_name\" already set to \"$correct_value\""
        fi
      fi
    fi
  fi
}
