# == Class: hive
#
# Apache Hive setup.
#
# [*metastore_hostname*] undef
#  Hostname of the metastore server. When specified, remote mode is activated (recommended).
#
# [*realm*] undef (TODO: used and required)
#   Kerberos realm. Use empty string if Kerberos is not used.
#
# [*properties*] undef
#   Additional properties.
#
# [*descriptions*] undef
#   Descriptions for the additional properties.
#
# [*alternatives*] 'cluster' or undef
#
#
class hive (
  $metastore_hostname = undef,
  $realm = undef,
  $properties = undef,
  $descriptions = undef,
  $alternatives = $hive::params::alternatives,
) inherits hive::params {
  include stdlib

  $dyn_properties = {
    'hive.metastore.warehouse.dir' => '/user/hive/warehouse',
    'datanucleus.autoStartMechanism' => 'SchemaTable',
  }

  if $metastore_hostname {
    $remote_properties = {
      'hive.metastore.uris' => "thrift://${hive::metastore_hostname}:${hive::port}",
    }
  }

  $dyn_descriptions = {}

  $_properties = merge($dyn_properties, $remote_properties, $properties)
  $_descriptions = merge($dyn_descriptions, $descriptions)
}
