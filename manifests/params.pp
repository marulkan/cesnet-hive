# == Class hive::params
#
# This class is meant to be called from hive
# It sets variables according to platform
#
class hive::params {
  case $::osfamily {
    'Debian': {
      $packages = {
        common => [ 'hive', 'hive-jdbc' ],
        metastore => 'hive-metastore',
        server => 'hive-server2',
        hcatalog => 'hive-hcatalog',
        hbase => 'hive-hbase',
      }
      $daemons = {
        metastore => 'hive-metastore',
        server => 'hive-server2',
      }
    }
    'RedHat': {
      $packages = {
        common => 'hive',
        hcatalog => 'hive-hcatalog',
      }
      $daemons = {
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $alternatives = $::osfamily ? {
    debian => 'cluster',
    redhat => undef,
  }
  $confdir = $::osfamily ? {
    debian => '/etc/hive/conf',
    redhat => '/etc/hive',
  }
  $db_name = 'metastore'
  $db_user = 'hive'
  $db_host = 'localhost'
  $port = 9083
  $group = 'users'
}
