#
# Cookbook Name:: hosts
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

nodes = search(:node, "chef_environment:#{node.chef_environment}")

template "/etc/hosts" do
  source "system-hosts.erb"
  mode "644"

  variables(
    :host_name => node['hostname'],
    :hosts => nodes 
  )
end
