# == Class hive::hcatalog::install
#
class hive::hcatalog::install {
  include stdlib
  contain hive::common::postinstall

  ensure_packages($hive::packages['hcatalog'])
  Package[$hive::packages['hcatalog']] -> Class['hive::common::postinstall']
}
