# == Class: zabbix_extras::agent::beegfs
#
# === Examples
#
#  class { 'zabbix_extras::agent::beegfs': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2015 Trey Dockendorf
#
class zabbix_extras::agent::beegfs (
  $ensure = 'present',
) {

  validate_re($ensure, ['^present$', '^absent$'])

  include ::zabbix::agent

  $metadata_iostat_path = "${::zabbix::agent::scripts_dir}/beegfs_metadata_iostat.sh"
  $storage_iostat_path  = "${::zabbix::agent::scripts_dir}/beegfs_storage_iostat.sh"

  zabbix::agent::userparameter { 'beegfs':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/beegfs.conf.erb'),
  }

  file { 'beegfs_metadata_iostat.sh':
    ensure => $ensure,
    path   => $metadata_iostat_path,
    source => 'puppet:///modules/zabbix_extras/agent/beegfs/metadata_iostat.sh',
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0755',
    before => Zabbix::Agent::Userparameter['beegfs'],
  }

  file { 'beegfs_storage_iostat.sh':
    ensure => $ensure,
    path   => $storage_iostat_path,
    source => 'puppet:///modules/zabbix_extras/agent/beegfs/storage_iostat.sh',
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0755',
    before => Zabbix::Agent::Userparameter['beegfs'],
  }

}
