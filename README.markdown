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
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

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
 * /etc/hive/\* (or /etc/hive/conf/*)
 * /usr/local/sbin/hivemanager (not needed, only when administrator manager script is requested by *features*)
* Alternatives:
 * alternatives are used for /etc/hive/conf in Cloudera
 * this module switches to the new alternative by default, so the Cloudera original configuration can be kept intact
* Services: only requested Hive services are setup and started
 * metastore
 * server2
* Helper Files:
 * /var/lib/hadoop-hdfs/.puppet-hive-dir-created (created by cesnet-hadoop module)
* Secret Files (keytabs): permissions are modified for hive service keytab (/etc/security/keytab/hive.service.keytab)

<a name="setup-requirements"></a>
###Setup Requirements

There are several known or intended limitations in this module.

Be aware of:

* **Repositories** - see cesnet-hadoop module Setup Requirements for details

* **no inter-node dependencies**: running HDFS namenode is required for Hive metastore server startup

* **secure mode**: keytabs must be prepared in /etc/security/keytabs/ (see *realm* parameter)

<a name="beginning-with-hive"></a>
###Beginning with Hive

Let's start with brief examples.

**Example 1**: The simplest setup without security nor zookeeper, with everything on single machine:

    class{"hive":
      metastore\_hostname => $::fqdn,
      # security needs to be disabled explicitly by using empty string
      realm => '',
    }

    node <HDFS_NODEMANAGER> {
      # HDFS initialization must be done on the namenode
      # (or you can create /user/hive on HDFS manually)
      include hive::hdfs
      Class['hadoop::namenode'] -> Class['hive::hdfs']
    }

    node $::fqdn {
      # server
      include hive::metastore
      include hive::server2
      # client
      include hive::frontend
      include hive::hcatalog
    }

Modify $::fqdn and node(s) section as needed.

It is recommended:

* using zookeeper and set hive parameter *zookeeper\_hostnames* (cesnet-zookeeper module can be used for installation of zookeeper)
* if collocated with HDFS namenode, add dependency *Class['hadoop::namenode::service'] -> Class['hive::metastore::service']*

**Example 2**: Setup with security:

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

Use nodes sections from **Example 1*, modify $::fqdn and nodes sections as needed.


<a name="usage"></a>
##Usage

TODO: Put the classes, types, and resources for customizing, configuring, and doing the fancy stuff with your module here.

<a name="security"></a>
###Enable Security

Security in Hadoop (and Hive) is based on Kerberos. Keytab files needs to be prepared on the proper places before enabling the security.

Following parameters are used for security (see also hive class):

* *realm* (required parameter, empty string disables the security)<br />
  Enable security and Kerberos realm to use. Empty string disables the security.
  To enable security, there are required:
  * installed Kerberos client (Debian: krb5-user/heimdal-clients; RedHat: krb5-workstation)
  * configured Kerberos client (/etc/krb5.conf, /etc/krb5.keytab)
  * /etc/security/keytab/hive.service.keytab (on all server nodes)

<a name="multihome"></a>
###Multihome Support

Multihome is supported by Hive out-of-the-box.

<a name="reference"></a>
##Reference

TODO: Here, list the classes, types, providers, facts, etc contained in your module. This section should include all of the under-the-hood workings of your module so people know what the module is touching on their system but don't need to mess with things. (We are working on automating this section!)

<a name="limitations"></a>
##Limitations

Idea in this module is to do only one thing - setup Hive SW - and don't limit generic usage of this module by doing other stuff. You can have your own repository with Hadoop SW, you can use this module just by *puppet apply* (PuppetDB is not used so puppet master is not required). You can select which Kerberos implementation or Java version to use.

On other hand this leads to some limitations as mentioned in [Setup Requirements](#setup-requirements) section and you may need site-specific puppet module together with this one.

<a name="development"></a>
##Development

* Repository: [http://scientific.zcu.cz/git/?p=cesnet-hive.git;a=summary](http://scientific.zcu.cz/git/?p=cesnet-hive.git;a=summary)
* Email: František Dvořák &lt;valtri@civ.zcu.cz&gt;
