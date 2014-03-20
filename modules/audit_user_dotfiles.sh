# audit_user_dotfiles
#
# While the system administrator can establish secure permissions for users'
# "dot" files, the users can easily override these.
# Group or world-writable user configuration files may enable malicious users to
# steal or modify other users' data or to gain another user's system privileges.
#.

audit_user_dotfiles () {
  if [ "$os_name" = "SunOS" ] || [ "$os_name" = "Linux" ]; then
    funct_verbose_message "User Dot Files"
    if [ "$audit_mode" != 2 ]; then
      echo "Checking:  User dot file permissions"
    fi
    check_fail=0
    for home_dir in `cat /etc/passwd |cut -f6 -d":" |grep -v "^/$"`; do
      for check_file in $home_dir/.[A-Za-z0-9]*; do
        if [ -f "$check_file" ]; then
          funct_check_perms $check_file 0600
        fi
      done
    done
  fi
}