# == Class hive::common::daemon
#
# Common settings for Hive daemons.
#
class hive::common::daemon {
  $keytab = '/etc/security/keytab/hive.service.keytab'

  if $hive::realm {
    file { $keytab:
      owner => 'hive',
      group => 'hive',
      mode  => '0400',
      alias => 'hive.service.keytab',
    }
  }
}
