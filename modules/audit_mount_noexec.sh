#!/bin/sh

# shellcheck disable=SC1090
# shellcheck disable=SC2034
# shellcheck disable=SC2154

# audit_mount_noexec
#
# Check No-exec on mounts
#
# Refer to Section(s) 1.1.4         Page(s) 14-5        CIS CentOS Linux 6 Benchmark v1.0.0
# Refer to Section(s) 1.1.4         Page(s) 17-8        CIS RHEL 5 Benchmark v2.1.0
# Refer to Section(s) 1.1.10,17,20  Page(s) 35,42,45    CIS RHEL 7 Benchmark v2.1.0
# Refer to Section(s) 2.4           Page(s) 16-7        CIS SLES 11 Benchmark v1.0.0
# Refer to Section(s) 1.1.2.[1-7].4 Page(s) 84-5,93-4,
#                                           118-9,127-8
#                                           136-7       CIS Ubuntu LTS 24.04 Benchmark v1.0.0
# Refer to Section(s) 1.1.3,5,10,17 Page(s) 27,29,34,41 CIS Amazon Linux Benchmark v2.0.0
#.

audit_mount_noexec () {
  print_function "audit_mount_noexec"
  if [ "${os_name}" = "Linux" ]; then
    verbose_message "No-exec on /tmp" "check"
    check_file="/etc/fstab"
    if [ -e "${check_file}" ]; then
      verbose_message "Temp File Systems mounted with noexec" "check"
      if [ "${audit_mode}" != "2" ]; then
        nodev_check=$( grep -v "^#" ${check_file} | grep "tmpfs" | grep -v noexec | head -1 | wc -l | sed "s/ //g" )
        if [ "${nodev_check}" = 1 ]; then
          if [ "${audit_mode}" = 1 ]; then
            increment_insecure  "Found tmpfs filesystems that should be mounted noexec"
            verbose_message     "cat ${check_file} | awk '( \$3 ~ /^tmpfs$/ ) { \$4 = \$4 \",noexec\" }; { printf \"%-26s %-22s %-8s %-16s %-1s %-1s\n\",\$1,\$2,\$3,\$4,\$5,\$6 }' > ${temp_file}" "fix"
            verbose_message     "cat ${temp_file} > ${check_file}" "fix"
            verbose_message     "rm ${temp_file}" "fix"
          fi
          if [ "${audit_mode}" = 0 ]; then
            verbose_message     "Setting:   Setting noexec on tmpfs"
            backup_file "${check_file}"
            awk '( $3 ~ /^tmpfs$/ ) { $4 = $4 ",noexec" }; { printf "%-26s %-22s %-8s %-16s %-1s %-1s\n",$1,$2,$3,$4,$5,$6 }' < "${check_file}" > "${temp_file}"
            cat "${temp_file}" > "${check_file}"
            if [ -f "${temp_file}" ]; then
              rm "${temp_file}"
            fi
          fi
        else
          if [ "${audit_mode}" = 1 ]; then
            increment_secure    "No filesystem that should be mounted with noexec"
          fi
          if [ "${audit_mode}" = 2 ]; then
            restore_file "${check_file}" "${restore_dir}"
          fi
        fi
      fi
      check_file_perms "${check_file}" "0644" "root" "root"
    fi
  fi
}
