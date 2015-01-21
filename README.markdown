####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with Hive](#setup)
    * [What cesnet-hive module affects](#what-hive-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with hive](#beginning-with-hive)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Enable Security](#security)
    * [Multihome Support](#multihome)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
    * [Module Parameters](#parameters)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

<a name="overview"></a>
##Overview

Management of Apache Hive data warehouse software. Puppet 3.x is required. Supported is the Debian (Cloudera distribution).

<a name="module-description"></a>
##Module Description

This module installs and setups Apache Hive data warehouse software running on the top of Hadoop cluster. Hive services can be collocated or separated across the hosts in the cluster. Optionally security based on Kerberos can be enabled. Security should be enabled if Hadoop cluster security is enabled.

Supported are:

* Fedora 21: only hive and hcatalog clients, native packages (tested on Hive 0.12.0)
* Debian 7/wheezy: Cloudera distribution (tested on Hive 0.13.1)

<a name="setup"></a>
##Setup

<a name="what-hive-affects"></a>
###What cesnet-hive module affects

* Packages: installs Hive packages (common packages, subsets for requested services, hcatalog, and/or hive client)
* Files modified:
 * */etc/hive/\** (or */etc/hive/conf/\**)
 * */usr/local/sbin/hivemanager* (not needed, only when administrator manager script is requested by *features*)
* Alternatives:
 * alternatives are used for */etc/hive/conf* in Cloudera
 * this module switches to the new alternative by default, so the Cloudera original configuration can be kept intact
* Services: only requested Hive services are setup and started
 * metastore
 * server2
* Helper Files:
 * */var/lib/hadoop-hdfs/.puppet-hive-dir-created* (created by cesnet-hadoop module)
* Secret Files (keytabs): permissions are modified for hive service keytab (*/etc/security/keytab/hive.service.keytab*)

<a name="setup-requirements"></a>
###Setup Requirements

There are several known or intended limitations in this module.

Be aware of:

* **Repositories** - see cesnet-hadoop module Setup Requirements for details

* **No inter-node dependencies**: running HDFS namenode is required for Hive metastore server startup

* **Secure mode**: keytabs must be prepared in /etc/security/keytabs/ (see *realm* parameter)

* **Database setup not handled here**: basic database setup and database creation needs to be handled externally; tested are puppetlabs-mysql ad puppetlabs-postgresql modules (see examples), but it is not limited to these modules

<a name="beginning-with-hive"></a>
###Beginning with Hive

Let's start with brief examples.

**Example**: The simplest setup without security nor zookeeper, with everything on single machine:

    class{"hive":
      hdfs_hostname => $::fqdn,
      metastore_hostname => $::fqdn,
      server2_hostname => $::fqdn,
      # security needs to be disabled explicitly by using empty string
      realm => '',
    }

    node <HDFS_NODEMANAGER> {
      # HDFS initialization must be done on the namenode
      # (or /user/hive on HDFS must be created)
      include hive::hdfs
      Class['hadoop::namenode::service'] -> Class['hive::hdfs']
    }

    node default {
      # server
      include hive::metastore
      include hive::server2
      # client
      include hive::frontend
      include hive::hcatalog
    }

Modify *$::fqdn* and node(s) section as needed.

It is recommended:

* using zookeeper and set hive parameter *zookeeper\_hostnames* (cesnet-zookeeper module can be used for installation of zookeeper)
* if collocated with HDFS namenode, add dependency *Class['hadoop::namenode::service'] -> Class['hive::metastore::service']*
* if not collocated, it is needed to have HDFS namenode running first, or restart Hive metastore later

<a name="usage"></a>
##Usage

It is highly recommended to use real database backends instead of Derby. Also security can be enabled.

See the examples:


**Example 1**: Setup with security:

Additional permissions in Hadoop cluster are needed: add hive proxy user.

    class{"hadoop":
    ...
      properties => {
        'hadoop.proxyuser.hive.groups' => 'hive,users',
        'hadoop.proxyuser.hive.hosts' => '*',
      },
    ...
    }

    class{"hive":
      group => 'users',
      metastore\_hostname => $::fqdn,
      # security needs to be disabled explicitly by using empty string
      realm => '',
    }

Use nodes sections from the initial **Example**, modify *$::fqdn* and nodes sections as needed.


**Example 2**: MySQL database, puppetlabs-mysql puppet module is used here.

Add this to the initial example:

    class{"hive":
      ...
      db => 'mysql',
      db_password => 'hivepassword',
    }

    node default {
      ...

      class { 'mysql::server':
        root_password  => 'strongpassword',
      }
    
      mysql::db { 'metastore':
        user     => 'hive',
        password => 'hivepassword',
        host     => 'localhost',
        grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
        sql      => '/usr/lib/hive/scripts/metastore/upgrade/mysql/hive-schema-0.13.0.mysql.sql',
      }
    
      class { 'mysql::bindings':
        java_enable => true,
      }
    
      Class['hive::metastore::install'] -> Mysql::Db['metastore']
      Mysql::Db['metastore'] -> Class['hive::metastore::service']
      Class['mysql::bindings'] -> Class['hive::metastore::config']
    }

As you can see, between *hive::metastore::install* and *hive::metastore::service* is included creation of the metastore MySQL database. The reason is the required schema SQL file goes from Hive packages, and the database is then needed for running Hive metastore.

The JDBC jar-file is also needed for metastore.


**Example 3**: PostgreSQL database, puppetlabs-postgresql puppet module is used here.

Add this to the initial example:

    class{"hive":
      ...
      db => 'postgresql',
      db_password => 'hivepassword',
    }

    node default {
      ...

      class { 'postgresql::server':
        postgres_password => 'strongpassword',
      }

      postgresql::server::db { 'metastore':
        user     => 'hive',
        password => postgresql_password('hive', 'hivepass'),
      }
      ->
      exec { 'metastore-import':
        command => 'cat /usr/lib/hive/scripts/metastore/upgrade/postgres/hive-schema-0.13.0.postgres.sql | psql metastore && touch /var/lib/hive/.puppet-hive-schema-imported',
        path    => '/bin/:/usr/bin',
        user    => 'hive',
        creates => '/var/lib/hive/.puppet-hive-schema-imported',
      }

      include postgresql::lib::java

      Class['postgresql::lib::java'] -> Class['hive::metastore::config']
      Class['hive::metastore::install'] -> Postgresql::Server::Db['metastore']
      Postgresql::Server::Db['metastore'] -> Class['hive::metastore::service']
      Exec['metastore-import'] -> Class['hive::metastore::service']
    }

Like with MySQL, between *hive::metastore::install* and *hive::metastore::service* is included creation of the metastore database, now PostgreSQL. The raeson is the required schema SQL file goes from Hive packages, and the database is then needed for running Hive metastore.

The JDBC jar-file is also needed for metastore.


<a name="security"></a>
###Enable Security

Security in Hadoop (and Hive) is based on Kerberos. Keytab files needs to be prepared on the proper places before enabling the security.

Following parameters are used for security (see also hive class):

* *realm* (required parameter, empty string disables the security)<br />
  Enable security and Kerberos realm to use. Empty string disables the security.
  To enable security, there are required:
  * installed Kerberos client (Debian: krb5-user/heimdal-clients; RedHat: krb5-workstation)
  * configured Kerberos client (*/etc/krb5.conf*, */etc/krb5.keytab*)
  * */etc/security/keytab/hive.service.keytab* (on all server nodes)

<a name="multihome"></a>
###Multihome Support

Multihome is supported by Hive out-of-the-box.

<a name="reference"></a>
##Reference

<a name="classes"></a>
###Classes

* **hbase** - Client Support for HBase
* **hdfs** - HDFS initialiations
* init
* params
* service
* common:
 * config
 * daemon
 * postinstall
* **frontend** - Client
 * config
 * install
* **hcatalog** - HCatalog Client
 * config
 * install
* **metastore** - Metastore
 * config
 * install
 * service
* **server2** - Server2
 * config
 * install
 * service

<a name="parameters"></a>
###Module Parameters

####`group` 'users'

Group where all users belong. It is not updated when changed, you should remove the /var/lib/hadoop-hdfs/.puppet-hive-dir-created file when changing or update group of /user/hive on HDFS.

####`metastore_hostname` undef

Hostname of the metastore server. When specified, remote mode is activated (recommended).

####`server2_hostname` undef

Hostname of the Hive server. Used only for hivemanager script.

####`zookeeper_hostnames` undef

Array of zookeeper hostnames quorum. Used for lock management (recommended).

####`zookeeper_port` undef

Zookeeper port, if different from the default (2181).

###`realm` undef

Kerberos realm. Use empty string if Kerberos is not used.

When security is enabled, you may also need to add these properties to Hadoop cluster:

* hadoop.proxyuser.hive.groups => 'hadoop,users' (where 'users' is the group in *group* parameter)
* hadoop.proxyuser.hive.hosts => '\*'

####`properties` undef

Additional properties.

####`descriptions` undef

Descriptions for the additional properties.

####`alternatives` 'cluster' or undef

Use alternatives to switch configuration. Use it only when supported (like with Cloudera for example).

####`db` undef

Database behind the metastore. The default is embeded database (*derby*), but it is recommended to use proper database.

Values:

* *derby* (default): embeded database
* *mysql*: MySQL/MariaDB,
* *postgresql*: PostgreSQL

####`db_host`: 'localhost'

Database hostname for *mysql*, *postgresql*, and *oracle*'. Can be overriden by *javax.jdo.option.ConnectionURL* property.

####`db_name`: 'metastore'

Database name for *mysql* and *postgresql*. For *oracle* 'xe' schema is used. Can be overriden by *javax.jdo.option.ConnectionURL* property.

####`db_user`: 'hive'

Database user for *mysql*, *postgresql*, and *oracle*.

####`db_password`: undef

Database password for *mysql*, *postgresql*, and *oracle*.

####`features` ()

Enable additional features:

* manager - script in /usr/local to start/stop Hive daemons relevant for given node


<a name="limitations"></a>
##Limitations

Idea in this module is to do only one thing - setup Hive SW - and don't limit generic usage of this module by doing other stuff. You can have your own repository with Hadoop SW, you can use this module just by *puppet apply*. You can select which Kerberos implementation, Java version, or database puppet module to use.

On other hand this leads to some limitations as mentioned in [Setup Requirements](#setup-requirements) section and you may need site-specific puppet module together with this one.

<a name="development"></a>
##Development

* Repository: [https://github.com/MetaCenterCloudPuppet/cesnet-hive](https://github.com/MetaCenterCloudPuppet/cesnet-hive)
* Testing: [https://github.com/MetaCenterCloudPuppet/hadoop-tests](https://github.com/MetaCenterCloudPuppet/hadoop-tests)
* Email: František Dvořák &lt;valtri@civ.zcu.cz&gt;
