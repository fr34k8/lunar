#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_account_switching
#
# Disabling the administrator's and/or user's ability to log into another user's active and
# locked session prevents unauthorized persons from viewing potentially sensitive and/or
# personal information.
#
# Refer to Section(s) 5.7 Page(s) 350-1 CIS Apple macOS 14 Sonoma Benchmark v1.0.0
#.

audit_account_switching () {
  print_function "audit_account_switching"
  if [ "${os_name}" = "Darwin" ]; then
    if [ "${long_os_version}" -ge 1014 ]; then
      ansible_counter=$((ansible_counter+1))
      ansible_value="audit_account_switching_${ansible_counter}"
      string="Administrator Account Login to Another User Session"
      verbose_message "${string}"
      if [ "${my_id}" != "0" ] && [ "${use_sudo}" = "0" ]; then
        verbose_message "Requires sudo to check" "notice"
        return
      fi
      if [ "${audit_mode}" != 2 ]; then
        correct_value="0"
        get_command="sudo /usr/bin/security authorizationdb read system.login.screensaver 2>&1 | /usr/bin/grep -c 'use-login-window-ui'"
        set_command="sudo /usr/bin/security authorizationdb write system.login.screensaver use-login-window-ui"
        current_value=$( eval "${get_command}" )
        if [ "${current_value}" = "${correct_value}" ]; then
          increment_secure   "Administrator Account Login to Another User Session is set to \"${correct_value}\""
        else
          increment_insecure "Administrator Account Login to Another User Session is not set to \"${correct_value}\""
        fi
        if [ "${ansible_mode}" = 1 ]; then
          echo ""
          echo "- name: Checking ${string}"
          echo "  command: sh -c \"${get_command}\""
          echo "  register: ${ansible_value}"
          echo "  failed_when: ${ansible_value} != 0"
          echo "  changed_when: false"
          echo "  ignore_errors: true"
          echo "  when: ansible_facts['ansible_system'] == '${os_name}'"
          echo ""
          echo "- name: Fixing ${string}"
          echo "  command: sh -c \"${set_command}\""
          echo "  when: ${ansible_value}.rc == 1 and ansible_facts['ansible_system'] == '${os_name}'"
          echo ""
        else
          lockdown_command="${set_command}"
          lockdown_message="Disable ${string}"
          execute_lockdown "${lockdown_command}" "${lockdown_message}" "sudo"
        fi
      fi
    fi
  fi
}
