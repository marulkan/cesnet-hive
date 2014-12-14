# == Class hive::metastore::service
#
class hive::metastore::service {
  service { $hive::daemons['metastore']:
    ensure    => 'running',
    enable    => true,
    subscribe => [File['hive-site.xml']],
  }
}
