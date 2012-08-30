#
# Cookbook Name:: ulimit
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

if node['platform'] == "ubuntu" or node['platform'] == "centos" then
  
  template "/etc/security/limits.conf" do
    source "limits.conf.erb"
    mode "644"
    user "root"
    group "root"

    variables(
      :grp => "hadoop"
    )
  end

  template "/etc/pam.d/common-session" do
    source "common-session.erb"
    mode "644"
    user "root"
    group "root"

    variables()
  end

end
