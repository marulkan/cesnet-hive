# == Class hive::hbase
#
# Hive Client support for HBase. It should be installed on client side with HBase.
#
class hive::hbase {
  include ::stdlib
  contain hive::common::config

  ensure_packages($hive::packages['hbase'])
  Package[$hive::packages['hbase']] -> Class['hive::common::postinstall']
}
