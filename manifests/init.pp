# == Class: hive
#
# Apache Hive setup.
#
# [*realm*] required
#   Kerberos realm. Use empty string if Kerberos is not used.
#
# [*alternatives*]
#
#
class hive (
  $realm = undef,
  $alternatives = $hive::params::alternatives,
) inherits hive::params {
  class { 'hive::install': } ->
  class { 'hive::config': } ~>
  class { 'hive::service': } ->
  Class['hive']
}
