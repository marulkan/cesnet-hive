# == Class hive::common::daemon
#
# Common settings for Hive daemons.
#
class hive::common::daemon {
  $keytab = '/etc/security/keytab/hive.service.keytab'

  if $hive::realm and $hive::realm != '' {
    if $hive::keytab_source and $hive::keytab_source != '' {
      file { $keytab:
        owner  => 'hive',
        group  => 'hive',
        mode   => '0400',
        alias  => 'hive.service.keytab',
        source => $hive::keytab_source,
      }
    } else {
      file { $keytab:
        owner => 'hive',
        group => 'hive',
        mode  => '0400',
        alias => 'hive.service.keytab',
      }
    }
  }

  if $hive::features['manager'] {
    file { '/usr/local/sbin/hivemanager':
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      alias   => 'hivemanager',
      content => template('hive/hivemanager.erb'),
    }
  }
}
