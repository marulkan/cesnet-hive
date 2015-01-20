# == Class hive::common::postinstall
#
# Preparation steps after installation. It switches hive-conf alternative, if enabled.
#
class hive::common::postinstall {
  $confname = $hive::alternatives
  $path = '/sbin:/usr/sbin:/bin:/usr/bin'

  if $confname {
    exec { 'hive-copy-config':
      command => "cp -a ${hive::confdir}/ /etc/hive/conf.${confname}",
      path    => $path,
      creates => "/etc/hive/conf.${confname}",
    }
    ->
    alternative_entry{"/etc/hive/conf.${confname}":
      altlink  => '/etc/hive/conf',
      altname  => 'hive-conf',
      priority => 50,
    }
    ->
    alternatives{'hive-conf':
      path => "/etc/hive/conf.${confname}",
    }
  }
}
