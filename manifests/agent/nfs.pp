# == Class: zabbix_extras::agent::nfs
#
class zabbix_extras::agent::nfs ($ensure = 'present') {

  validate_re($ensure, ['^present$', '^absent$'])

  include ::zabbix::agent

  zabbix::agent::userparameter { 'nfs':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/nfs.conf.erb'),
  }

}
