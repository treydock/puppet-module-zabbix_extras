# == Class: zabbix_extras::agent::smart
#
class zabbix_extras::agent::smart ($ensure = 'present', $manage_sudo = true) {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_bool($manage_sudo)

  include ::zabbix::agent

  zabbix::agent::userparameter { 'smart':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/smart.conf.erb'),
  }

  if $manage_sudo {
    zabbix::agent::sudo { 'smart':
      command => '/usr/sbin/smartctl -H /dev/*',
    }
  }

}
