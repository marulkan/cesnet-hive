# == Class hive::hdfs
#
# HDFS initialiations. Actions necessary to launch on HDFS namenode: Create hive user, if needed. Creates directory structure on HDFS for Hive. It needs to be called after Hadoop HDFS is working (its namenode and proper number of datanodes) and before Hive service startup.
#
# This class is needed to be launched on HDFS namenode. With some limitations it can be launched on any Hadoop node (user hive created or hive installed on namenode, kerberos ticket available on the local node).
#
class hive::hdfs {
  # create user/group if needed (we don't need to install hive just for user, unless it is colocated with the namenode)
  group { 'hive':
    ensure => present,
    system => true,
  }
  case "${::osfamily}/${::operatingsystem}" {
    'RedHat/Fedora': {
      user { 'hive':
        ensure     => present,
        system     => true,
        comment    => 'Apache Hive',
        gid        => 'hive',
        home       => '/var/lib/hive',
        managehome => true,
        password   => '!!',
        shell      => '/sbin/nologin',
      }
    }
    'Debian/Debian', 'Debian/Ubuntu', 'RedHat/CentOS', 'RedHat/RedHat', 'RedHat/Scientific': {
      user { 'hive':
        ensure     => present,
        system     => true,
        comment    => 'Hive User',
        gid        => 'hive',
        home       => '/var/lib/hive',
        managehome => true,
        password   => '!!',
        shell      => '/bin/false',
      }
    }
    default: {
      notice("${::osfamily} not supported")
    }
  }
  Group['hive'] -> User['hive']

  $touchfile = 'hive-dir-created'
  hadoop::kinit { 'hive-kinit':
    touchfile => $touchfile,
  }
  ->
  hadoop::mkdir { '/user/hive':
    mode      => '0755',
    owner     => 'hive',
    group     => $hive::group,
    touchfile => $touchfile,
  }
  ->
  hadoop::mkdir { $hive::_properties['hive.metastore.warehouse.dir']:
    mode      => '1775',
    owner     => 'hive',
    group     => $hive::group,
    touchfile => $touchfile,
  }
  ->
  hadoop::kdestroy { 'hive-kdestroy':
    touchfile => $touchfile,
    touch     => true,
  }
}

