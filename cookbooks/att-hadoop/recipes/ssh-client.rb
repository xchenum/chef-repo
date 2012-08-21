#
# Cookbook Name:: ssh-client
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template "/etc/ssh/ssh_config" do
  source "ssh_config.erb"
  mode "644"

end
