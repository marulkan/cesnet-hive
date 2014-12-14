# == Class hive::common::config
#
# Basic configuration for Hive.
#
class hive::common::config {
  file { "${hive::confdir}/hive-site.xml":
    alias   => 'hive-site.xml',
    content => template('hive/hive-site.xml.erb'),
  }
}
