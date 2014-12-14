# == Class hive::install
#
class hive::install {
  include stdlib
  contain hive::common::postinstall

  ensure_packages($hive::package_name)
  Package[$hive::package_name] -> Class['hive::common::postinstall']
}
