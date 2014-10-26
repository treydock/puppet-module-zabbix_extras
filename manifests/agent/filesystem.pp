# == Class: zabbix_extras::agent::filesystem
#
class zabbix_extras::agent::filesystem (
  $ensure = 'present',
) {

  validate_re($ensure, ['^present$', '^absent$'])

  include ::zabbix::agent

  $checkro_path = "${::zabbix::agent::scripts_dir}/checkro.sh"

  zabbix::agent::userparameter { 'filesystem':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/filesystem.conf.erb'),
  }

  file { 'checkro.sh':
    ensure => $ensure,
    path   => $checkro_path,
    source => 'puppet:///modules/zabbix_extras/agent/filesystem/checkro.sh',
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0755',
    before => Zabbix::Agent::Userparameter['filesystem'],
  }

}
