# == Class hive::server2::install
#
# Installation of Hive server2 service.
#
class hive::server2::install {
  include ::stdlib
  contain hive::common::postinstall

  ensure_packages($hive::packages['server'])
  Package[$hive::packages['server']] -> Class['hive::common::postinstall']
}
