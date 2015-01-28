# == Class: zabbix_extras::agent::dell
#
class zabbix_extras::agent::dell ($ensure = 'present') {

  if $::manufacturer =~ /Dell/ {
    validate_re($ensure, ['^present$', '^absent$'])

    include ::zabbix::agent

    zabbix::agent::userparameter { 'dell':
      ensure  => $ensure,
      content => template('zabbix_extras/agent/dell.conf.erb'),
    }
  }

}
