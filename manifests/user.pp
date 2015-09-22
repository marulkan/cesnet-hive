# == Class hive::user
#
# Create hive system user, if needed. The hive user is required on the all HDFS namenodes to autorization work properly and we don't need to install hive just for the user.
#
# It is better to handle creating the user by the packages, so we recommend dependecny on installation classes or Hivepackages.
#
class hive::user {
  group { 'hive':
    ensure => present,
    system => true,
  }
  case "${::osfamily}-${::operatingsystem}" {
    /RedHat-Fedora/: {
      user { 'hive':
        ensure     => present,
        system     => true,
        comment    => 'Apache Hive',
        gid        => 'hive',
        home       => '/var/lib/hive',
        managehome => true,
        password   => '!!',
        shell      => '/sbin/nologin',
      }
    }
    /Debian|RedHat/: {
      user { 'hive':
        ensure     => present,
        system     => true,
        comment    => 'Hive User',
        gid        => 'hive',
        home       => '/var/lib/hive',
        managehome => true,
        password   => '!!',
        shell      => '/bin/false',
      }
    }
    default: {
      notice("${::osfamily} not supported")
    }
  }
  Group['hive'] -> User['hive']
}
