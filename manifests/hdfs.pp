# == Class hive::hdfs
#
# HDFS initialiations. Actions necessary to launch on HDFS namenode: Create hive user, if needed. Creates directory structure on HDFS for Hive. It needs to be called after Hadoop HDFS is working (its namenode and proper number of datanodes) and before Hive service startup.
#
# This class is needed to be launched on HDFS namenode. With some limitations it can be launched on any Hadoop node (user hive created or hive installed on namenode, kerberos ticket available on the local node).
#
class hive::hdfs {
  include ::hive::user

  $touchfile = 'hive-dir-created'
  hadoop::kinit { 'hive-kinit':
    touchfile => $touchfile,
  }
  ->
  hadoop::mkdir { '/user/hive':
    mode      => $hive::_warehouse_mode,
    owner     => 'hive',
    group     => $hive::_group,
    touchfile => $touchfile,
  }
  ->
  hadoop::mkdir { $hive::_properties['hive.metastore.warehouse.dir']:
    mode      => '1775',
    owner     => 'hive',
    group     => $hive::_group,
    touchfile => $touchfile,
  }
  ->
  hadoop::kdestroy { 'hive-kdestroy':
    touchfile => $touchfile,
    touch     => true,
  }
}

