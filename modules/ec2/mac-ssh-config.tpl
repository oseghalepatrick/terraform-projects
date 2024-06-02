cat << EOF >> ~/.ssh/config

Host airflow-${user}
  HostName ${hostname}
  User ${user}
  IdentityFile ${identityfile}
EOF