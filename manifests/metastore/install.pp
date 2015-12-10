# == Class hive::metastore::install
#
# Installation of Hive metastore service.
#
class hive::metastore::install {
  include ::stdlib
  contain hive::common::postinstall

  ensure_packages($hive::packages['metastore'])
  Package[$hive::packages['metastore']] -> Class['hive::common::postinstall']
}
