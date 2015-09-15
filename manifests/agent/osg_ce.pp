# == Class: zabbix_extras::agent::osg_ce
#
# === Examples
#
#  class { 'zabbix_extras::agent::osg_ce': }
#
# === Authors
#
# Trey Dockendorf <treydock@gmail.com>
#
# === Copyright
#
# Copyright 2015 Trey Dockendorf
#
class zabbix_extras::agent::osg_ce (
  $ensure = 'present',
) {

  validate_re($ensure, ['^present$', '^absent$'])

  include ::zabbix::agent

  $schedd_ad_script_path = "${::zabbix::agent::scripts_dir}/htcondor-ce-schedd-ad.py"

  zabbix::agent::userparameter { 'osg-ce':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/osg-ce.conf.erb'),
  }

  file { 'htcondor-ce-schedd-ad.py':
    ensure => $ensure,
    path   => $schedd_ad_script_path,
    source => 'puppet:///modules/zabbix_extras/agent/osg-ce/htcondor-ce-schedd-ad.py',
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0755',
    before => Zabbix::Agent::Userparameter['osg-ce'],
  }

}
