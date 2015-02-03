# == Class: zabbix_extras::agent::proc
#
class zabbix_extras::agent::proc (
  $ensure = 'present',
) {

  validate_re($ensure, ['^present$', '^absent$'])

  include ::zabbix::agent

  zabbix::agent::userparameter { 'proc':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/proc.conf.erb'),
  }

}
