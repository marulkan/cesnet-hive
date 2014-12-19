# == Class hive::server2::config
#
# Configuration of Hive server2 service.
#
class hive::server2::config {
  contain hive::common::config
  contain hive::common::daemon
}
