# audit_sendmail_greeting
#
#.

audit_sendmail_greeting () {
  if [ "$os_name" = "SunOS" ] || [ "$os_name" = "Linux" ]; then
    check_file="/etc/mail/sendmail.cf"
    if [ -f "$check_file" ]; then
      funct_verbose_message "Sendmail Greeting"
      search_string="v/"
      restore=0
      if [ "$audit_mode" != 2 ]; then
        total=`expr $total + 1`
        check_value=`cat $check_file |grep -v '^#' |grep 'O SmtpGreetingMessage' |awk '{print $4}' |grep 'v/'`
        if [ "$check_value" = "$search_string" ]; then
          if [ "$audit_mode" = "1" ]; then
            insecure=`expr $insecure + 1`
            echo "Warning:   Found version information in sendmail greeting [$insecure Warnings]"
            funct_verbose_message "" fix
            funct_verbose_message "cp $check_file $temp_file" fix
            funct_verbose_message 'cat $temp_file |awk '/O SmtpGreetingMessage=/ { print "O SmtpGreetingMessage=Mail Server Ready; $b"; next} { print }' > $check_file' fix
            funct_verbose_message "rm $temp_file" fix
            funct_verbose_message "" fix
          fi
          if [ "$audit_mode" = 0 ]; then
            funct_backup_file $check_file
            echo "Setting:   Sendmail greeting to have no version information"
            cp $check_file $temp_file
            cat $temp_file |awk '/O SmtpGreetingMessage=/ { print "O SmtpGreetingMessage=Mail Server Ready; $b"; next} { print }' > $check_file
            rm $temp_file
          fi
        else
          if [ "$audit_mode" = "1" ]; then
            secure=`expr $secure + 1`
            echo "Secure:    No version information in sendmail greeting [$secure Passes]"
          fi
        fi
      else
        funct_restore_file $check_file $restore_dir
      fi
      funct_disable_value $check_file "O HelpFile" hash
      if [ "$audit_mode" != 2 ]; then
        total=`expr $total + 1`
        check_value=`cat $check_file |grep -v '^#' |grep '$search_string'`
        if [ "$check_value" = "$search_string" ]; then
          if [ "$audit_mode" = "1" ]; then
            insecure=`expr $insecure + 1`
            echo "Warning:   Found help information in sendmail greeting [$insecure Warnings]"
          fi
          if [ "$audit_mode" = 0 ]; then
            funct_backup_file $check_file
            echo "Setting:   Sendmail to have no help information"
            cp $check_file $temp_file
            cat $temp_file |sed 's/^O HelpFile=/#O HelpFile=/' > $check_file
            rm $temp_file
          fi
        else
          if [ "$audit_mode" = "1" ]; then
            secure=`expr $secure + 1`
            echo "Secure:    No help information in sendmail greeting [$secure Passes]"
          fi
        fi
      else
        funct_restore_file $check_file $restore_dir
      fi
      funct_check_perms $check_file 0444 root root
    fi
  fi
}
