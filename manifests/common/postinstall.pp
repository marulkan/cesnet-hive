# == Class hive::common::postinstall
#
# Preparation steps after installation. It switches hive-conf alternative, if enabled.
#
class hive::common::postinstall {
  ::hadoop_lib::postinstall{ 'hive':
    alternatives => $::hive::alternatives,
  }
}
