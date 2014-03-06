transport { 'winrm':
  server   => '192.168.1.1',
  username => 'administrator',
  password => 'password',
}

exec { 'Set-ExecutionPolicy Unrestricted':
  unless    => '$result = (Get-ExecutionPolicy); $result -eq "Unrestricted"',
  logoutput => on_failure,
  provider  => 'winrm_ps',
  transport => Transport['winrm'],
}
