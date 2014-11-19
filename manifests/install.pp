# == Class hive::install
#
class hive::install {
  include stdlib

  # hive on HDFS namenode needed for the directory layout setup script
  if $hive::hdfs_hostname == $::fqdn or member($hive::frontends, $::fqdn) {
    ensure_packages($hive::package_name)
  }
}
