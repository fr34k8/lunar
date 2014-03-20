# audit_duplicate_groups
#
# Duplicate groups may result in escalation of privileges through administative
# error.
# Although the groupadd program will not let you create a duplicate Group ID
# (GID), it is possible for an administrator to manually edit the /etc/group
# file and change the GID field.
#
# Although the groupadd program will not let you create a duplicate group name,
# it is possible for an administrator to manually edit the /etc/group file and
# change the group name.
# If a group is assigned a duplicate group name, it will create and have access
# to files with the first GID for that group in /etc/groups. Effectively, the
# GID is shared, which is a security problem.
#.

audit_duplicate_groups () {
  if [ "$os_name" = "SunOS" ] || [ "$os_name" = "Linux" ]; then
    funct_verbose_message "Duplicate Groups"
    audit_duplicate_ids 1 groups name /etc/group
    audit_duplicate_ids 3 groups id /etc/group
  fi
}