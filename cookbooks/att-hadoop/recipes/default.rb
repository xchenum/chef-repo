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

if node.chef_environment.include?("caas") then
  include_recipe "hosts"
end

def get_ip(n)
  if node['network']
    return node['network']['ipaddress_eth0'] ||
           node['network']['ipaddress_eth1'] ||
           node['network']['ipaddress_eth2']
  else
    return nil
  end
end                                 

if node['roles'].include?("hd-master") then

  include_recipe "ssh-client"

  ips = []
  search(:node, "chef_environment:#{node.chef_environment} AND role:hd-slave").each() do |n|
    ips.push( get_ip(n) )
  end
  ips = ips.sort()
  
  if node['hadoop']['cluster_size'] then
      # limit the size of the cluster
    if ips.length >= node['hadoop']['cluster_size']-1 then
      ips = ips[0 ... node['hadoop']['cluster_size']-1]
    end
  end

  secondary = []
  search(:node, "chef_environment:#{node.chef_environment} AND role:hd-secondary").each() do |n|
    secondary.push( get_ip(n) ) 
  end

  if secondary.length == 0 then
    secondary.push( get_ip(node) )
  end


  template node['hadoop']['masters'] do
    source "hosts.erb"
    mode "644"
    user node['hadoop']['user']
    group node['hadoop']['group']

    variables(
      :hosts => secondary
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

  directory "/home/" + node['hadoop']['user'] + "/.ssh" do
    user node['hadoop']['user']
    group node['hadoop']['group']
    mode "755"
    action :create
  end

  template "/home/" + node['hadoop']['user'] + "/.ssh/config" do
    source "ssh_config.erb"
    mode "700"
    user node['hadoop']['user']
    group node['hadoop']['group']
  end
end

if node['roles'].include?("hd-secondary") then
  template node['hadoop']['conf.hadoop.site'] do
    source "hadoop-site.xml.erb"
    mode "644"
    user node['hadoop']['user']
    group node['hadoop']['group']

    variables(
      :namenode_addr => search(:node, "chef_environment:#{node.chef_environment} AND role:hd-master")[0]['network']['ipaddress_eth0']
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


