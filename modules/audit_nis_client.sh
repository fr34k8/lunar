#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_nis_client
#
# Check NIS client
#
# Refer to Section(s) 2.5   Page(s) 18      CIS Solaris 11.1 Benchmark v1.0.0
# Refer to Section(s) 2.2.3 Page(s) 24-5    CIS Solaris 10 Benchmrk v5.1.0
# Refer to Section(s) 2.1.5 Page(s) 58      CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 2.1.5 Page(s) 53      CIS RHEL 6 Benchmark v1.2.0
# Refer to Section(s) 2.3.1 Page(s) 123     CIS RHEL 7 Benchmark v2.1.0
# Refer to Section(s) 5.1.2 Page(s) 41      CIS SLES 11 Benchmark v1.0.0
# Refer to Section(s) 2.3.1 Page(s) 110-1   CIS Amazon Linux Benchmark v2.0.0
# Refer to Section(s) 2.3.1 Page(s) 119-20  CIS Ubuntu 16.04 Benchmark v2.0.0
# Refer to Section(s) 2.2.1 Page(s) 292-3   CIS Ubuntu 16.04 Benchmark v2.0.0
#.

audit_nis_client () {
  print_function "audit_nis_client"
  if [ "${os_name}" = "SunOS" ] || [ "${os_name}" = "Linux" ]; then
    verbose_message "NIS Client Daemons" "check"
    if [ "${os_name}" = "SunOS" ]; then
      if [ "${os_version}" = "10" ] || [ "${os_version}" = "11" ]; then
        check_sunos_service "svc:/network/nis/client" "disabled"
      fi
    fi
    if [ "${os_name}" = "Linux" ]; then
      for service_name in ypbind nis; do
        check_linux_service "${service_name}" "off"
        check_linux_package "uninstall"       "${service_name}"
      done
    fi
  fi
}
