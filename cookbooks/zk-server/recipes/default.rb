#
# Cookbook Name:: zk-server
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "zookeeperd" do
  action :upgrade
end

service "zookeeper" do
  supports :restart => true

  action [ :nothing ]
end

servers = search(:node, "chef_environment:#{node.chef_environment} AND role:zk-server") || []

def gen_myid(servers)
  (1..servers.length).each do |i|
    if servers[i-1]['hostname'] == node["hostname"]:
      return i
    end
  end
  Chef::Log.info "cannot find myself in the list of zk-servers"
end

my_zk_id = gen_myid(servers)

template node["zk-server"]["myid"] do
  source "myid.erb"
  mode "0644"

  variables(
    :myid   => my_zk_id
  )
  
  notifies :restart, resources(:service => "zookeeper")
end

template node["zk-server"]["cfg"] do
  source "zoo.cfg.erb"
  mode "0644"

  variables(
    :servers => servers    
  )

  notifies :restart, resources(:service => "zookeeper")
end
