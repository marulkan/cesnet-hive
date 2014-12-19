# == Class hive::params
#
# This class is meant to be called from hive
# It sets variables according to platform
#
class hive::params {
  case $::osfamily {
    'Debian': {
      $packages = {
        common => 'hive',
        metastore => 'hive-metastore',
      }
      $daemons = {
        metastore => 'hive-metastore',
      }
    }
    'RedHat': {
      $packages = {
        common => 'hive',
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
  $port = 9083
  $group = 'users'
}
