# == Class hive::common::config
#
# Basic configuration for Hive.
#
class hive::common::config {
  file { "${hive::confdir}/hive-site.xml":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    alias   => 'hive-site.xml',
    content => template('hive/hive-site.xml.erb'),
  }
}
