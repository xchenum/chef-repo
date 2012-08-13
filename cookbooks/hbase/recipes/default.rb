#
# Cookbook Name:: hbase
# Recipe:: default
#
# Copyright 2010, Runa Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# include_recipe "java"

Chef::Log.debug("Top of hbase::default")

# if node.run_list.roles.include?("hbase-master") then
#   include_recipe "hbase::master"
# end
# 
# if node['roles'].include?("hbase-regionserver") then
#   include_recipe "hbase::regionserver"
# end

script "install hbase" do
  user "root"
  interpreter "bash"
  cwd "/usr/local"
  code <<-EOH
    wget http://www.gtlib.gatech.edu/pub/apache/hbase/stable/hbase-0.94.1.tar.gz -O hbase.tar.gz
    tar zxvf hbase.tar.gz
    dir=`ls /usr/local | grep hbase | grep -v tar.gz`
    mv $dir hbase
    mkdir /usr/local/hbase/logs
    chown hduser:hadoop hbase -R
  EOH
  not_if "test -d /usr/local/hbase"
end


# Get the zookeeper nodes
zk_servers = []
search(:node, "chef_environment:#{node.chef_environment} AND role:zk-server").each() do |zk|
  zk_servers.push( zk['hostname'] )
end
zk_server_str = zk_servers.join(",")

hd = search(:node, "chef_environment:#{node.chef_environment} AND role:hd-master")

template node['hbase']['dir'] + "/conf/hbase-site.xml" do
  source "hbase-site.xml.erb"
  mode 0664
  owner node['hbase']['user']
  group node['hbase']['group']
  variables(
    :hbase_master_host => hd[0]['hostname'] + ":54310",
    :zookeeper_quorum => zk_server_str
  )
end

template node['hbase']['dir'] + "/conf/hbase-env.sh" do
  source "hbase-env.sh.erb"
  mode 0664
  owner node['hbase']['user']
  group node['hbase']['group']
  variables(
    :hbase_dir => "/usr/local/hbase"
  )
end

regionservers = []
search(:node, "chef_environment:#{node.chef_environment} AND role:hbase-regionserver").each() do |r|
  regionservers.push( r['hostname'] )
end

template node['hbase']['dir'] + "/conf/regionservers" do
  source "regionservers.erb"
  mode 0664
  owner node['hbase']['user']
  group node['hbase']['group']
  variables(
    :regionservers => regionservers
  )
end
