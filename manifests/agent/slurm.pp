# == Class: zabbix_extras::agent::slurm
#
class zabbix_extras::agent::slurm (
  $ensure = 'present',
) {

  validate_re($ensure, ['^present$', '^absent$'])

  include ::zabbix::agent

  zabbix::agent::userparameter { 'slurm':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/slurm.conf.erb'),
  }

}
