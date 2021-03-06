# audit_dcui
#
# Refer to http://pubs.vmware.com/vsphere-55/topic/com.vmware.vsphere.security.doc/GUID-6779F098-48FE-4E22-B116-A8353D19FF56.html
#.

audit_dcui () {
  if [ "$os_name" = "VMkernel" ]; then
    funct_verbose_message "DCUI"
    funct_chkconfig_service DCUI off
    funct_verbose_message "Lockdown"
    total=`expr $total + 1`
    backup_file="$work_dir/dvfilter"
    current_value=`vim-cmd -U dcui vimsvc/auth/lockdown_is_enabled`
    if [ "$audit_mode" != "2" ]; then
      if [ "$current_value" != "true" ]; then
        if [ "$audit_more" = "0" ]; then
          echo "$current_value" > $backup_file
          echo "Setting:   Lockdown to true"
           vim-cmd -U dcui vimsvc/auth/lockdown_mode_enter
        fi
        if [ "$audit_mode" = "1" ]; then
          insecure=`expr $insecure + 1`
          echo "Warning:   Lockdown is disabled [$insecure Warnings]"
          funct_verbose_message "" fix
          funct_verbose_message "vim-cmd -U dcui vimsvc/auth/lockdown_mode_enter" fix
          funct_verbose_message "" fix
        fi
      else
        if [ "$audit_mode" = "1" ]; then
          secure=`expr $secure + 1`
          echo "Secure:    Lockdown is enabled [$secure Passes]"
          echo ""
        fi
      fi
    else
      restore_file="$restore_dir/$test"
      if [ -f "$restore_file" ]; then
        previous_value=`cat $restore_file`
        if [ "$previous_value" != "$current_value" ]; then
          echo "Restoring: Lockdown to $previous_value"
          if [ "$previous_value" = "true" ]; then
            vim-cmd -U dcui vimsvc/auth/lockdown_mode_enter
          else
            vim-cmd -U dcui vimsvc/auth/lockdown_mode_exit
          fi
        fi
      fi
    fi
  fi
}
