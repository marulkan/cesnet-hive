# == Class hive::common::postinstall
#
# Preparation steps after installation. It switches hive-conf alternative, if enabled.
#
class hive::common::postinstall {
  $confname = $hive::alternatives
  $path = '/sbin:/usr/sbin:/bin:/usr/bin'
  $altcmd = $::osfamily ? {
    debian => 'update-alternatives',
    redhat => 'alternatives',
  }

  if $confname {
    exec { 'hive-copy-config':
      command => "cp -a ${hive::confdir}/ /etc/hive/conf.${confname}",
      path    => $path,
      creates => "/etc/hive/conf.${confname}",
    }
    ->
    exec { 'hive-install-alternatives':
      command     => "${altcmd} --install /etc/hive/conf hive-conf /etc/hive/conf.${confname} 50",
      path        => $path,
      refreshonly => true,
      subscribe   => Exec['hive-copy-config'],
    }
    ->
    exec { 'hive-set-alternatives':
      command     => "${altcmd} --set hive-conf /etc/hive/conf.${confname}",
      path        => $path,
      refreshonly => true,
      subscribe   => Exec['hive-copy-config'],
    }
  }
}
