# == Class: zabbix_extras::agent::x509
#
# === Examples
#
#  class { 'zabbix_extras::agent::x509': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2015 Trey Dockendorf
#
class zabbix_extras::agent::x509 (
  $ensure = 'present',
) {

  validate_re($ensure, ['^present$', '^absent$'])

  include ::zabbix::agent

  $expiration_script_path = "${::zabbix::agent::scripts_dir}/x509_expiration.sh"

  zabbix::agent::userparameter { 'x509':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/x509.conf.erb'),
  }

  file { 'x509_expiration.sh':
    ensure => $ensure,
    path   => $expiration_script_path,
    source => 'puppet:///modules/zabbix_extras/agent/x509/x509_expiration.sh',
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0755',
    before => Zabbix::Agent::Userparameter['x509'],
  }

}
