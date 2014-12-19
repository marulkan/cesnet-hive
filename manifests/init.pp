# == Class: hive
#
# Apache Hive setup.
#
# [*group*] 'users'
#  Group where all users belong.
#
# [*metastore_hostname*] undef
#  Hostname of the metastore server. When specified, remote mode is activated (recommended).
#
# [*realm*] undef
#   Kerberos realm. Use empty string if Kerberos is not used.
#
#   When security is enabled, you may also need to add these properties to Hadoop cluster:
#   - hadoop.proxyuser.hive.users
#   - hadoop.proxyuser.hive.groups
#   - hadoop.proxyuser.hive.hosts
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
  $group = $hive::params::group,
  $metastore_hostname = undef,
  $realm,
  $properties = undef,
  $descriptions = undef,
  $alternatives = $hive::params::alternatives,
) inherits hive::params {
  include stdlib

  $dyn_properties = {
    'hive.metastore.warehouse.dir' => '/user/hive/warehouse',
    'datanucleus.autoStartMechanism' => 'SchemaTable',
  }

  if $hive::metastore_hostname {
    $remote_properties = {
      'hive.metastore.uris' => "thrift://${hive::metastore_hostname}:${hive::port}",
    }
  }

  if $hive::realm {
    $sec_properties = {
      'hive.metastore.sasl.enabled' => true,
      'hive.metastore.kerberos.keytab.file' => '/etc/security/keytab/hive.service.keytab',
      'hive.metastore.kerberos.principal' => "hive/_HOST@${hive::realm}",
      'hive.metastore.pre.event.listeners' => 'org.apache.hadoop.hive.ql.security.authorization.AuthorizationPreEventListener',
      'hive.security.metastore.authorization.manager' => 'org.apache.hadoop.hive.ql.security.authorization.StorageBasedAuthorizationProvider',
      'hive.security.metastore.authenticator.manager' => 'org.apache.hadoop.hive.ql.security.HadoopDefaultMetastoreAuthenticator',
    }
  }

  $dyn_descriptions = {
      'hive.metastore.pre.event.listeners' => 'turn on metastore-side authorization security',
      'hive.security.metastore.authorization.manager' => 'recommended is the HDFS permissions-based model: StorageBasedAuthorizationProvider',
      'hive.security.metastore.authenticator.manager' => 'just magic from https://cwiki.apache.org/confluence/display/Hive/Storage+Based+Authorization+in+the+Metastore+Server',
  }

  $_properties = merge($dyn_properties, $remote_properties, $sec_properties, $properties)
  $_descriptions = merge($dyn_descriptions, $descriptions)
}
