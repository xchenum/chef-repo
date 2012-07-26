#
# Cookbook Name:: att-hadoop
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


include_recipe "att-hadoop::hdfs"
include_recipe "att-hadoop::mapred"

if node['roles'].include?("hd-master")
  ips = []
  search(:node, "chef_environment:#{node.chef_environment} AND role:hd-slave").each() do |n|
    ips.push( n["network"]["ipaddress_eth0"] || n["network"]["ipaddress_eth1"] )
  end

  lip = node["network"]["ipaddress_eth0"] # || node["network"]["ipaddress_eth1"]
  ips.push(lip)

  template node['hadoop']['masters'] do
    source "hosts.erb"
    mode "644"
    user node['hadoop']['user']
    group node['hadoop']['group']

    variables(
      :hosts => [ lip ]
    )
  end

  template node['hadoop']['slaves'] do
    source "hosts.erb"
    mode "644"
    user node['hadoop']['user']
    group node['hadoop']['group']

    variables(
      :hosts => ips
    )
  end

end

directory node['hadoop']['ramdisk'] do
  user node['hadoop']['user']
  group node['hadoop']['group']
  mode "755"
  action :create
end

mount node['hadoop']['ramdisk'] do
  pass 0
  fstype "tmpfs"
  device "/dev/null"
  options "nr_inodes=999k,mode=755,size=20480m"
  if node['hadoop']['useram']
    action [:mount, :enable]
  else
    action [:umount]
  end
end
