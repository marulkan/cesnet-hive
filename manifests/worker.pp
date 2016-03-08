# == Class hive::worker
#
# Hive support at the worker node.
#
class hive::worker {
  include ::hive::worker::install
}
