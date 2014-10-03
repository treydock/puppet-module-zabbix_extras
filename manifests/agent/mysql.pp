# == Class: zabbix_extras::agent::mysql
#
class zabbix_extras::agent::mysql (
  $ensure             = 'present',
  $include_mysql      = true,
  $mysql_username     = 'UNSET',
  $mysql_password     = 'UNSET',
  $mysql_hostname     = 'UNSET',
  $zabbix_agent_home  = 'UNSET',
) {

  validate_re($ensure, ['^present$', '^absent$'])
  validate_bool($include_mysql)

  include ::zabbix::agent

  if $include_mysql and $ensure == 'present' {
    include ::mysql::server::monitor
    Class['::mysql::server::monitor'] -> Class['zabbix_extras::agent::mysql']

    $mysql_monitor_username = $mysql_username ? {
      'UNSET' => $::mysql::server::monitor::mysql_monitor_username ? {
        undef   => 'UNSET',
        default => $::mysql::server::monitor::mysql_monitor_username,
      },
      default => $mysql_username,
    }
    $mysql_monitor_password = $mysql_password ? {
      'UNSET' => $::mysql::server::monitor::mysql_monitor_password ? {
        undef   => 'UNSET',
        default => $::mysql::server::monitor::mysql_monitor_password,
      },
      default => $mysql_password,
    }
    $mysql_monitor_hostname = $mysql_hostname ? {
      'UNSET' => $::mysql::server::monitor::mysql_monitor_hostname ? {
        undef   => 'localhost',
        default => $::mysql::server::monitor::mysql_monitor_hostname,
      },
      default => $mysql_hostname,
    }
  }

  $zabbix_agent_home_real = $zabbix_agent_home ? {
    'UNSET' => $::zabbix::agent::user_home_dir ? {
      undef   => '/var/lib/zabbix',
      default => $::zabbix::agent::user_home_dir,
    },
    default => $zabbix_agent_home,
  }

  zabbix::agent::userparameter { 'mysql':
    ensure  => $ensure,
    content => template('zabbix_extras/agent/mysql.conf.erb'),
  }

  file { "${zabbix_agent_home_real}/.my.cnf":
    ensure  => $ensure,
    content => template('zabbix_extras/agent/my.cnf.erb'),
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0400',
    before  => Zabbix::Agent::Userparameter['mysql'],
  }

}
