# == Class: hive
#
# Apache Hive setup.
#
# [*group*] 'users'
#
#  Group where all users belong. It is not updated when changed, you should remove the /var/lib/hadoop-hdfs/.puppet-hive-dir-created file when changing or update group of /user/hive on HDFS.
#
# [*metastore_hostname*] undef
#
#  Hostname of the metastore server. When specified, remote mode is activated (recommended).
#
# [*server2_hostname*] undef
#
#  Hostname of the Hive server. Used only for hivemanager script.
#
# [*zookeeper_hostnames*] undef
#
#  Array of zookeeper hostnames quorum. Used for lock management (recommended).
#
# [*zookeeper_port*] undef
#
#  Zookeeper port, if different from the default (2181).
#
# [*realm*] undef
#
#   Kerberos realm. Use empty string if Kerberos is not used.
#
#   When security is enabled, you may also need to add these properties to Hadoop cluster:
#
#   * hadoop.proxyuser.hive.groups => 'hadoop,users' (where 'users' is the group in *group* parameter)
#   * hadoop.proxyuser.hive.hosts => '\*'
#
# [*properties*] undef
#
#   Additional properties.
#
# [*descriptions*] undef
#
#   Descriptions for the additional properties.
#
# [*alternatives*] 'cluster' or undef
#
# [*features*] ()
#
#   Enable additional features:
#
#   * manager - script in /usr/local to start/stop Hive daemons relevant for given node
#
class hive (
  $group = $hive::params::group,
  $metastore_hostname = undef,
  $server2_hostname = undef,
  $zookeeper_hostnames = undef,
  $zookeeper_port = undef,
  $realm,
  $properties = undef,
  $descriptions = undef,
  $alternatives = $hive::params::alternatives,
  $features = undef,
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

  if $zookeeper_hostnames {
    $zoo_properties1 = {
      'hive.support.concurrency' => true,
      'hive.zookeeper.quorum' => join($zookeeper_hostnames, ',')
    }
    if $zookeeper_port {
      $zoo_properties2 = {
        'hive.zookeeper.client.port' => $zookeeper_port,
      }
    }
    $zoo_properties = merge($zoo_properties1, $zoo_properties2)
  } else {
    notice('zookeeper quorum, not specified, recommended for locking')
  }

  if $hive::realm {
    $sec_properties = {
      'hive.metastore.sasl.enabled' => true,
      'hive.metastore.kerberos.keytab.file' => '/etc/security/keytab/hive.service.keytab',
      'hive.metastore.kerberos.principal' => "hive/_HOST@${hive::realm}",
      'hive.metastore.pre.event.listeners' => 'org.apache.hadoop.hive.ql.security.authorization.AuthorizationPreEventListener',
      'hive.security.metastore.authorization.manager' => 'org.apache.hadoop.hive.ql.security.authorization.StorageBasedAuthorizationProvider',
      'hive.security.metastore.authenticator.manager' => 'org.apache.hadoop.hive.ql.security.HadoopDefaultMetastoreAuthenticator',
      'hive.server2.authentication' => 'KERBEROS',
      'hive.server2.authentication.kerberos.principal' => "hive/_HOST@${hive::realm}",
      'hive.server2.authentication.kerberos.keytab' => '/etc/security/keytab/hive.service.keytab',
      'hive.server2.enable.impersonation' => true,
      'hive.server2.thrift.sasl.qop' => 'auth',
    }
  }

  $dyn_descriptions = {
      'hive.metastore.pre.event.listeners' => 'turn on metastore-side authorization security',
      'hive.security.metastore.authorization.manager' => 'recommended is the HDFS permissions-based model: StorageBasedAuthorizationProvider',
      'hive.security.metastore.authenticator.manager' => 'just magic from https://cwiki.apache.org/confluence/display/Hive/Storage+Based+Authorization+in+the+Metastore+Server',
      'hive.server2.enable.impersonation' => 'execute queries and access HDFS files as the connected user rather than the super user',
      'hive.server2.thrift.sasl.qop' => 'auth, auth-int, auth-conf (only "auth" is working with Kerberos)',
  }

  $_properties = merge($dyn_properties, $remote_properties, $zoo_properties, $sec_properties, $properties)
  $_descriptions = merge($dyn_descriptions, $descriptions)
}
