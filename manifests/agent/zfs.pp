# == Class: zabbix_extras::agent::zfs
#
class zabbix_extras::agent::zfs (
  $ensure               = 'present',
  $trapper_ensure       = 'UNSET',
  $manage_sudo          = true,
  $manage_trapper       = true,
  $trapper_zpools       = ['tank'],
  $trapper_filesystems  = ['tank'],
  $trapper_minute       = '*/5',
  $trapper_hour         = '*',
) {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_re($trapper_ensure, ['^UNSET$', '^present$', '^absent$'])
  validate_bool($manage_sudo)
  validate_bool($manage_trapper)
  validate_array($trapper_zpools)
  validate_array($trapper_filesystems)

  $trapper_ensure_real = $trapper_ensure ? {
    'UNSET' => $ensure,
    default => $trapper_ensure,
  }

  include ::zabbix::agent

  $zfs_trapper_path = "${::zabbix::agent::scripts_dir}/zfs_trapper.sh"

  zabbix::agent::userparameter { 'zfs':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/zfs.conf.erb'),
  }

  if $manage_sudo and $ensure == 'present' {
    zabbix::agent::sudo { 'zfs':
      command => [
        '/sbin/zpool list *',
        '/sbin/zpool get *',
        '/sbin/zfs list *',
        '/sbin/zfs get *',
      ],
    }
  }

  file { 'zfs_trapper.sh':
    ensure => $ensure,
    path   => $zfs_trapper_path,
    source => 'puppet:///modules/zabbix_extras/agent/zfs/zfs_trapper.sh',
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0755',
    before => Zabbix::Agent::Userparameter['zfs'],
  }

  if $manage_trapper {
    file { 'zabbix-zfs-trapper':
      ensure  => $trapper_ensure_real,
      path    => '/etc/cron.d/zabbix-zfs-trapper',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('zabbix_extras/agent/zabbix-zfs-trapper.erb'),
      require => File['zfs_trapper.sh'],
    }
  }

}
