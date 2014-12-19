# == Class hive::hcatalog
#
# Deploy HCatalog. To be used on the frontend.
#
# It requires Hive metastore in remote mode.
#
class hive::hcatalog {
  include 'hive::hcatalog::install'
  include 'hive::hcatalog::config'

  Class['hive::hcatalog::install'] ->
  Class['hive::hcatalog::config'] ->
  Class['hive::hcatalog']
}
