# == Class: zabbix_extras::agent::discovery
#
class zabbix_extras::agent::discovery (
  $ensure = 'present',
) {

  include ::zabbix::agent

  $block_device_discovery_path = "${::zabbix::agent::scripts_dir}/block_device_discovery.rb"

  zabbix::agent::userparameter { 'discovery':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/discovery.conf.erb'),
  }

  file { 'block_device_discovery.rb':
    ensure => $ensure,
    path   => $block_device_discovery_path,
    source => 'puppet:///modules/zabbix_extras/agent/discovery/block_device_discovery.rb',
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0755',
    before => Zabbix::Agent::Userparameter['discovery'],
  }

}
