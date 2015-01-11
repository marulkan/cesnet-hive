# == Class hive::hcatalog::config
#
# Configuration of Hive hcatalog.
#
class hive::hcatalog::config {
  contain hive::common::config

  if !$hive::metastore_hostname {
    notice('metastore_hostname not specified, HCatalog requires Hive Metastore in remote mode')
  }
}
