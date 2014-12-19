# == Class hive::server2::service
#
class hive::server2::service {
  service { $hive::daemons['server']:
    ensure    => 'running',
    enable    => true,
    subscribe => [File['hive-site.xml']],
  }
}
