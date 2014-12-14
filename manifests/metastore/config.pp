# == Class hive::metastore::config
#
# Configuration of Hive metastore service.
#
class hive::metastore::config {
  contain hive::common::config
  contain hive::common::daemon
}
