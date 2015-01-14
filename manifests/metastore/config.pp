# == Class hive::metastore::config
#
# Configuration of Hive metastore service.
#
class hive::metastore::config {
  contain hive::common::config
  contain hive::common::daemon

  if $hive::db == 'mysql' or $hive::db == 'mariadb' {
    file { '/usr/lib/hive/lib/mysql-connector-java.jar':
      ensure => 'link',
      links  => 'follow',
      source => '/usr/share/java/mysql-connector-java.jar',
    }
  }

  if $hive::db == 'postgresql' {
    file { '/usr/lib/hive/lib/postgresql-jdbc.jar':
      ensure => 'link',
      links  => 'follow',
      source => '/usr/share/java/postgresql.jar',
    }
  }
}
