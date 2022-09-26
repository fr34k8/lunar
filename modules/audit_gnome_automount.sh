# audit_gnome_automount
#
# Refer to Section(s) 1.8.6 Page(s) 172-7  CIS Ubuntu 22.04 Benchmaek v1.0.0
# Refer to Section(s) 1.8.7 Page(s) 178-82 CIS Ubuntu 22.04 Benchmaek v1.0.0
#.

audit_gnome_automount () {
  if [ "$os_name" = "Linux" ]; then
    verbose_message "Automount for GNOME Users"
    check_gsettings_value org.gnome.desktop.media-handling automount-open false
    check_gsettings_value org.gnome.desktop.media-handling automount false
    if [ "$os_vendor" = "Ubuntu" ]; then
      if [ $os_release -ge 22 ]; then 
        check_file="/etc/dconf/db/ibus.d/00-media-automount"
        if [ "$ansible" = 1 ]; then
          string="Automount GNOME Users"
          echo "- name: $string"
          echo "  copy:"
          echo "    content: |"
          echo "             [org/gnome/desktop/media-handling]"
          echo "             automount-open=false"
          echo "             automount=false"
          echo "    dest: $check_file"
        fi
        if [ -f "$check_file" ]; then
          check_file_value is $check_file "automount-false" eq "false" hash after "handling"
          check_file_value is $check_file "automount" eq "false" hash after "handling"
        else
          if [ "$audit_mode" = 1 ]; then
            verbose_message "" fix
            verbose_message "echo \"[org/gnome/desktop/media-handling]\" > $check_file" fix
            verbose_message "echo \"automount-open=false\" >> $check_file" fix
            verbose_message "echo \"automount=false\" >> $check_file" fix
            verbose_message "dconf update" fix
            verbose_message "" fix
          fi 
          if [ "$audit_mode" = 0 ]; then
            echo "[org/gnome/desktop/media-handling]" > $check_file
            echo "automount-open=false" >> $check_file
            echo "automount=false" >> $check_file
            dconf update
          fi          
          if [ "$audit_mode" = 2 ]; then
            rm $check_file
          fi
        fi
        check_file="/etc/dconf/db/ibus.d/locks/00-media-automount"
        if [ "$ansible" = 1 ]; then
          string="Automount Lock GNOME Users"
          echo "- name: $string"
          echo "  copy:"
          echo "    content: |"
          echo "             /org/gnome/desktop/media-handling/automount]"
          echo "             /org/gnome/desktop/media-handling/automount-open"
          echo "    dest: $check_file"
        fi
        if [ -f "$check_file" ]; then
          check_file_value is $check_file "automount-false" eq "false" hash after "handling"
          check_file_value is $check_file "automount" eq "false" hash after "handling"
        else
          if [ "$audit_mode" = 1 ]; then
            verbose_message "" fix
            verbose_message "mkdir /etc/dconf/db/ibus.d/locks" fix
            verbose_message "echo \"/org/gnome/desktop/media-handling/automount\" > $check_file" fix
            verbose_message "echo \"/org/gnome/desktop/media-handling/automount-open\" >> $check_file" fix
            verbose_message "echo \"automount=false\" >> $check_file" fix
            verbose_message "dconf update" fix
            verbose_message "" fix
          fi 
          if [ "$audit_mode" = 0 ]; then
            mkdir /etc/dconf/db/ibus.d/locks
            echo "/org/gnome/desktop/media-handling/automount" > $check_file
            echo "/org/gnome/desktop/media-handling/automount-open" > $check_file
            dconf update
          fi          
          if [ "$audit_mode" = 2 ]; then
            rm $check_file
          fi
        fi
      fi
    fi
  fi
}