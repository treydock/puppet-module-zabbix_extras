# == Class: zabbix_extras::agent::edac
#
class zabbix_extras::agent::edac ($ensure = 'present') {

  validate_re($ensure, ['^present$', '^absent$'])

  include ::zabbix::agent

  zabbix::agent::userparameter { 'edac':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/edac.conf.erb'),
  }

}
