add-content -path c:/users/PC/.ssh/config -value @'

Host ${user}
  HostName ${hostname}
  User ${user}
  IdentityFile ${identityfile}
'@