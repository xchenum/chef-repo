#
# Author:: Robert J. Berger (rberger@runa.com)
# Cookbook Name:: hbase
# Recipe:: master
#
# Copyright 2010, Runa, Inc.
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

Chef::Log.debug("Top of hbase::master")

if node['roles'].include?("hbase-master") then
  template "/etc/init.d/hbase_master" do
    source "master_init_d.erb"
    mode 0755
    owner 'root'
    group 'root'
    variables(
      :hbase_dir => node['hbase']['dir'],
      :hbase_user => node['hbase']['user']
    )
  end

  service "hbase_master" do
    supports :restart => true
    action [ :enable, :start ]
  end
end