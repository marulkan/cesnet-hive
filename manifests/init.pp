# == Class: hive
#
# Apache Hive setup.
#
# [*hdfs_hostname*] required
#  HDFS namenode hostname. There will be launched commands for setup directory layout.
#
# [*frontends*] ([])
#   Hostnames of frontends.
#
class hive (
  $hdfs_hostname,
  $frontends = [],
) inherits hive::params {
  class { 'hive::install': } ->
  class { 'hive::config': } ~>
  class { 'hive::service': } ->
  Class['hive']
}
