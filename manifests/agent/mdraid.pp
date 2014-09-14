# == Class: zabbix_extras::agent::mdraid
#
# === Examples
#
#  class { 'zabbix_extras::agent::mdraid': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zabbix_extras::agent::mdraid (
  $ensure = 'present',
) {

  validate_re($ensure, ['^present$', '^absent$'])

  include ::zabbix::agent

  $mdraid_discovery_path = "${::zabbix::agent::scripts_dir}/mdraid_discovery.rb"

  zabbix::agent::userparameter { 'mdraid':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/mdraid.conf.erb'),
  }

  file { 'mdraid_discovery.rb':
    ensure  => $ensure,
    path    => $mdraid_discovery_path,
    source  => 'puppet:///modules/zabbix_extras/agent/mdraid/mdraid_discovery.rb',
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0755',
    before  => Zabbix::Agent::Userparameter['mdraid'],
  }

}
