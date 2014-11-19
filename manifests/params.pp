# == Class hive::params
#
# This class is meant to be called from hive
# It sets variables according to platform
#
class hive::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'hive'
    }
    'RedHat': {
      $package_name = 'hive'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
