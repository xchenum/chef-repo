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

servers = search("node", "role:#{zk-server}") || []

def gen_myid(servers):
  for i in 1..servers.length
    if servers[i-1] == node["hostname"]:
      return i
    end
  end
  Chef::Log.info "cannot find myself in the list of zk-servers"
end

template node["zk-server"]["myid"] do
  source "myid.erb"
  mode "0640"

  variables(
    :myid   => gen_myid(servers)
  )
  
  notifies :restart, resources(:service => "zookeeper")
end

template node["zk-server"]["cfg"] do
  source "zoo.cfg.erb"
  mode "0640"

  variables(
    :servers => servers    
  )

  notifies :restart, resources(:service => "zookeeper")
end
