#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# full_audit_shell_services
#
# Audit remote shell services
#.

full_audit_shell_services () {
  print_function "full_audit_shell_services"
  audit_issue_banner
  audit_ssh_config
  audit_ssh_perms
  audit_remote_consoles
  audit_ssh_forwarding
  audit_remote_shell
  audit_console_login
  audit_security_banner
  audit_xinetd_server
  audit_telnet_banner
  audit_telnet_server
  audit_talk_server
  audit_talk_client
  audit_pam_rhosts
  audit_user_netrc
  audit_user_rhosts
  audit_rhosts_files
  audit_netrc_files
  audit_serial_login
  audit_sulogin
  audit_shell_timeout
  audit_esxi_shell
}
