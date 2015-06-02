# == Class hive::params
#
# This class is meant to be called from hive
# It sets variables according to platform
#
class hive::params {
  case "${::osfamily}/${::operatingsystem}" {
    'Debian/Debian', 'Debian/Ubuntu', 'RedHat/CentOS', 'RedHat/RedHat', 'RedHat/Scientific': {
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
    'RedHat/Fedora': {
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

  $alternatives = "${::osfamily}-${::operatingsystem}" ? {
    /Fedora-RedHat/ => undef,
    # let's disable alternatives for now:
    # https://github.com/puppet-community/puppet-alternatives/issues/18
    /RedHat/        => undef,
    /Debian/        => 'cluster',
  }
  $confdir = "${::osfamily}-${::operatingsystem}" ? {
    /Fedora-RedHat/ => '/etc/hive',
    /Debian|RedHat/ => '/etc/hive/conf',
  }
  $db_name = 'metastore'
  $db_user = 'hive'
  $db_host = 'localhost'
  $port = 9083
  $group = 'users'
}
