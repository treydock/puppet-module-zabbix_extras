# == Class: zabbix_extras::params
#
# The zabbix_extras default configuration settings.
#
class zabbix_extras::params {

  case $::osfamily {
    'RedHat': {
      # Do nothing
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}
