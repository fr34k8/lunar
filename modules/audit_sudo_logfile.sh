#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_sudo_logfile
#
# Check sudo logfile
#
# Refer to Section(s) 5.2.3 Page(s) 585-7 CIS Ubuntu 24.04 Benchmark v1.0.0
#.

audit_sudo_logfile () {
  print_function "audit_sudo_logfile"
  if [ "${os_name}" = "Darwin" ] || [ "${os_name}" = "Linux" ] || [ "${os_name}" = "SunOS" ]; then
    verbose_message "Sudo logfile" "check"
    if [ "${my_id}" != "0" ] && [ "${use_sudo}" = "0" ]; then
      verbose_message "Requires sudo to check" "notice"
      return
    fi
    if [ -d "/etc/sudoers.d" ]; then
      check_file="/etc/sudoers.d/logfile"
    else
      check_file="/etc/sudoers"
    fi
    check_file_value "is"  "${check_file}" "Defaults logfile" "eq" "/var/log/sudo.log" "hash"
    check_file_perms "${check_file}" "440" "root" "${wheel_group}" 
  fi
}
