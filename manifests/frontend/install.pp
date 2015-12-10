# == Class hive::frontend::install
#
class hive::frontend::install {
  include ::stdlib
  contain hive::common::postinstall

  ensure_packages($hive::packages['common'])
  Package[$hive::packages['common']] -> Class['hive::common::postinstall']
}
