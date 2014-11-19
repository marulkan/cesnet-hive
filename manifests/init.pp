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
# [*realm*] required
#   Kerberos realm. Use empty string if Kerberos is not used.
#
class hive (
  $hdfs_hostname,
  $frontends = [],
  $realm,
) inherits hive::params {
  class { 'hive::install': } ->
  class { 'hive::config': } ~>
  class { 'hive::service': } ->
  Class['hive']
}
