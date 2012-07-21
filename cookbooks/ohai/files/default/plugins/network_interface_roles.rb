#
# Cookbook Name:: ohai
# Plugin:: network_interface_roles
#
# Copyright 2012, AT&T Services, Inc.
#

provides "network"

require_plugin "hostname"
require_plugin "#{os}::network"

network['interfaces'].each do |iface, addrs|
  ip = addrs['addresses'].select { |address, data| data["family"] == "inet" }.keys[0]

  network['mgmt_ipv4'] = ip if iface == "bond0"
  network['ops_ipv4'] = ip if iface == "bond1.2001"
  network['public_ipv4'] = ip if (iface == "bond1.2004" || iface == "bond1.2002")
  network['sw_mgmt_ipv4'] = ip if iface == "bond0.100"
  network['ips_mgmt_ipv4'] = ip if iface == "bond0.120"
end

network
