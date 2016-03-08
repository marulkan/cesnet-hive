# == Class: hive::worker::install
#
# Install packages needed on the worker nodes.
#
class hive::worker::install {
  include ::stdlib

  ensure_packages($hive::packages['worker'])
}
