# == Class: hive
#
# Apache Hive setup.
#
# ####`group` 'users'
#
# Group where all users belong. It is not updated when changed, you should remove the /var/lib/hadoop-hdfs/.puppet-hive-dir-created file when changing or update group of /user/hive on HDFS.
#
# ####`hdfs_hostname` undef
#
# HDFS hostname (or defaultFS value), if different from core-site.xml Hadoop file. It is recommended to have the *core-site.xml* file instead. *core-site.xml* will be created when installing any Hadoop component or if you include *hadoop::common::config* class.
#
# ####`metastore_hostname` undef
#
# Hostname of the metastore server. When specified, remote mode is activated (recommended).
#
# ####`server2_hostname` undef
#
# Hostname of the Hive server. Used only for hivemanager script.
#
# ####`zookeeper_hostnames` undef
#
# Array of zookeeper hostnames quorum. Used for lock management (recommended).
#
# ####`zookeeper_port` undef
#
# Zookeeper port, if different from the default (2181).
#
# ###`realm` undef
#
# Kerberos realm. Use empty string if Kerberos is not used.
#
# When security is enabled, you may also need to add these properties to Hadoop cluster:
#
# * hadoop.proxyuser.hive.groups => 'hadoop,users' (where 'users' is the group in *group* parameter)
# * hadoop.proxyuser.hive.hosts => '\*'
#
# ####`properties` undef
#
# Additional properties.
#
# ####`descriptions` undef
#
# Descriptions for the additional properties.
#
# ####`alternatives` 'cluster' or undef
#
# Use alternatives to switch configuration. Use it only when supported (like with Cloudera for example).
#
# ####`db` undef
#
# Database behind the metastore. The default is embeded database (*derby*), but it is recommended to use proper database.
#
# Values:
#
# * *derby* (default): embeded database
# * *mysql*: MySQL/MariaDB,
# * *postgresql*: PostgreSQL
#
# ####`db_host`: 'localhost'
#
# Database hostname for *mysql*, *postgresql*, and *oracle*'. Can be overriden by *javax.jdo.option.ConnectionURL* property.
#
# ####`db_name`: 'metastore'
#
# Database name for *mysql* and *postgresql*. For *oracle* 'xe' schema is used. Can be overriden by *javax.jdo.option.ConnectionURL* property.
#
# ####`db_user`: 'hive'
#
# Database user for *mysql*, *postgresql*, and *oracle*.
#
# ####`db_password`: undef
#
# Database password for *mysql*, *postgresql*, and *oracle*.
#
# ####`features` {}
#
# Enable additional features:
#
# * manager - script in /usr/local to start/stop Hive daemons relevant for given node
#
class hive (
  $group = $hive::params::group,
  $hdfs_hostname = undef,
  $metastore_hostname = undef,
  $server2_hostname = undef,
  $zookeeper_hostnames = undef,
  $zookeeper_port = undef,
  $realm,
  $properties = undef,
  $descriptions = undef,
  $alternatives = $hive::params::alternatives,
  $db = undef,
  $db_host = $hive::params::db_host,
  $db_user = $hive::params::db_user,
  $db_name = $hive::params::db_name,
  $db_password = undef,
  $features = {},
) inherits hive::params {
  include stdlib

  if $metastore_hostname == $::fqdn {
    case $db {
      'derby',default: {
        $db_properties = {
          'javax.jdo.option.ConnectionURL' => 'jdbc:derby:;databaseName=/var/lib/hive/metastore/metastore_db;create=true',
          'javax.jdo.option.ConnectionDriverName' => 'org.apache.derby.jdbc.EmbeddedDriver',
        }
      }
      'mysql','mariadb': {
        $db_properties = {
          'javax.jdo.option.ConnectionURL' => "jdbc:mysql://${db_host}/${db_name}",
          'javax.jdo.option.ConnectionDriverName' => 'com.mysql.jdbc.Driver',
          'javax.jdo.option.ConnectionUserName' => $db_user,
          'javax.jdo.option.ConnectionPassword' => $db_password,
          'datanucleus.autoCreateSchema' => false,
          'datanucleus.fixedDatastore' => true,
          'hive.metastore.schema.verification' => true,
        }
      }
      'postgresql': {
        $db_properties = {
          'javax.jdo.option.ConnectionURL' => "jdbc:postgresql://${db_host}/${db_name}",
          'javax.jdo.option.ConnectionDriverName' => 'org.postgresql.Driver',
          'javax.jdo.option.ConnectionUserName' => $db_user,
          'javax.jdo.option.ConnectionPassword' => $db_password,
          'datanucleus.autoCreateSchema' => false,
          'datanucleus.fixedDatastore' => true,
          'hive.metastore.schema.verification' => true,
        }
      }
      'oracle': {
        $db_properties = {
          'javax.jdo.option.ConnectionURL' => "jdbc:oracle:thin:@//${db_host}/xe",
          'javax.jdo.option.ConnectionDriverName' => 'oracle.jdbc.OracleDriver',
          'javax.jdo.option.ConnectionUserName' => $db_user,
          'javax.jdo.option.ConnectionPassword' => $db_password,
          'datanucleus.autoCreateSchema' => false,
          'datanucleus.fixedDatastore' => true,
          'hive.metastore.schema.verification' => true,
        }
      }
    }
  }

  if $hdfs_hostname {
    $metastore_uri = "hdfs://${hive::hdfs_hostname}"
  }
  $dyn_properties = {
    'datanucleus.autoStartMechanism' => 'SchemaTable',
    'hive.metastore.warehouse.dir' => "${metastore_uri}/user/hive/warehouse",
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
      'javax.jdo.option.ConnectionURL' => 'JDBC connect string for a JDBC metastore',
      'javax.jdo.option.ConnectionDriverName' => 'Driver class name for a JDBC metastore',
      'hive.metastore.pre.event.listeners' => 'turn on metastore-side authorization security',
      'hive.security.metastore.authorization.manager' => 'recommended is the HDFS permissions-based model: StorageBasedAuthorizationProvider',
      'hive.security.metastore.authenticator.manager' => 'just magic from https://cwiki.apache.org/confluence/display/Hive/Storage+Based+Authorization+in+the+Metastore+Server',
      'hive.server2.enable.impersonation' => 'execute queries and access HDFS files as the connected user rather than the super user',
      'hive.server2.thrift.sasl.qop' => 'auth, auth-int, auth-conf (only "auth" is working with Kerberos)',
  }

  $_properties = merge($db_properties, $dyn_properties, $remote_properties, $zoo_properties, $sec_properties, $properties)
  $_descriptions = merge($dyn_descriptions, $descriptions)
}
