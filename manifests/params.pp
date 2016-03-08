# == Class hive::params
#
# This class is meant to be called from hive
# It sets variables according to platform
#
class hive::params {
  case "${::osfamily}-${::operatingsystem}" {
    /RedHat-Fedora/: {
      $packages = {
        common => 'hive',
        hcatalog => 'hive-hcatalog',
      }
      $daemons = {
      }
    }
    /Debian|RedHat/: {
      $packages = {
        common => [ 'hive', 'hive-jdbc' ],
        metastore => 'hive-metastore',
        server => 'hive-server2',
        hcatalog => 'hive-hcatalog',
        hbase => 'hive-hbase',
        worker => 'hive-jdbc',
      }
      $daemons = {
        metastore => 'hive-metastore',
        server => 'hive-server2',
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $confdir = "${::osfamily}-${::operatingsystem}" ? {
    /Fedora-RedHat/ => '/etc/hive',
    /Debian|RedHat/ => '/etc/hive/conf',
  }
  $db_name = 'metastore'
  $db_user = 'hive'
  $db_host = 'localhost'
  $port = 9083
}
