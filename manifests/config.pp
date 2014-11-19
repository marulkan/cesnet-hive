# == Class hive::config
#
# This class is called from hive
#
class hive::config {
  $realm = $hive::realm

  # call this only on HDFS namenode
  # (easier for getting neccessary privileges)
  if $hive::hdfs_hostname == $::fqdn {
    $touchfile = '/var/tmp/.puppet-hive-dirs-created'
    $env = [ 'KRB5CCNAME=FILE:/tmp/krb5cc_nn_puppet' ]
    $path = '/sbin:/usr/sbin:/bin:/usr/bin'

    # destroy it only when needed though
    exec { 'hive-kdestroy':
      command     => 'kdestroy',
      path        => $path,
      environment => $env,
      onlyif      => "test -n \"${realm}\"",
      creates     => $touchfile,
    }
    ->
    exec { 'hive-kinit':
      command     => "runuser hdfs -s /bin/bash /bin/bash -c \"kinit -k nn/${::fqdn}@${realm} -t /etc/security/keytab/nn.service.keytab\"",
      path        => $path,
      environment => $env,
      onlyif      => "test -n \"${realm}\"",
      creates     => $touchfile,
    }
    ->
    exec { 'hive-homedir':
      command     => 'runuser hdfs -s /bin/bash /bin/bash -c \"hdfs dfs -mkdir /user/hive\"',
      path        => $path,
      environment => $env,
      creates     => $touchfile,
    }
    ->
    exec { 'hive-dirs':
      command     => "runuser hdfs -s /bin/bash /bin/bash -c /usr/bin/init-hive-dfs.sh",
      path        => $path,
      environment => $env,
      creates     => $touchfile,
    }
    ->
    exec { 'hive-chown':
      command     => "runuser hdfs -s /bin/bash /bin/bash -c \"hdfs dfs -chown :users /user/hive/warehouse\" && touch ${touchfile}",
      path        => $path,
      environment => $env,
      creates     => $touchfile,
    }
  }
}
