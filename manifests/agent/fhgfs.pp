# == Class: zabbix_extras::agent::fhgfs
#
# === Examples
#
#  class { 'zabbix_extras::agent::fhgfs': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2013 Trey Dockendorf
#
class zabbix_extras::agent::fhgfs (
  $ensure = 'present',
) {

  validate_re($ensure, ['^present$', '^absent$'])

  include ::zabbix::agent

  $metadata_iostat_path = "${::zabbix::agent::scripts_dir}/fhgfs_metadata_iostat.sh"
  $storage_iostat_path  = "${::zabbix::agent::scripts_dir}/fhgfs_storage_iostat.sh"

  zabbix::agent::userparameter { 'fhgfs':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/fhgfs.conf.erb'),
  }

  file { 'fhgfs_metadata_iostat.sh':
    ensure  => $ensure,
    path    => $metadata_iostat_path,
    source  => 'puppet:///modules/zabbix_extras/agent/fhgfs/metadata_iostat.sh',
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0755',
    before  => Zabbix::Agent::Userparameter['fhgfs'],
  }

  file { 'fhgfs_storage_iostat.sh':
    ensure  => $ensure,
    path    => $storage_iostat_path,
    source  => 'puppet:///modules/zabbix_extras/agent/fhgfs/storage_iostat.sh',
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0755',
    before  => Zabbix::Agent::Userparameter['fhgfs'],
  }

}
