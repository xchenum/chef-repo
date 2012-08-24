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

def get_ip(n)
  if n['network']
    return n['network']['ipaddress_eth0'] ||
           n['network']['ipaddress_eth1'] ||
           n['network']['ipaddress_eth2']
  else
    return nil
  end
end

def get_ips(nodes, role)
  res = []
  nodes.each() do |n|
    if n['roles'] and n['roles'].include?(role)
      res.push( get_ip(n) )
    end
  end
  return res
end

all_nodes = search(:node, "chef_environment:#{node.chef_environment}")

if node.chef_environment.include?("caas") then
  template "/etc/hosts" do
    source "system-hosts.erb"
    mode "644"

    variables(
      :host_name => node['hostname'],
      :hosts => all_nodes
    )
  end
end

if node['roles'].include?("hd-master") then

  include_recipe "att-hadoop::ssh-client"

  slave_ips = get_ips(all_nodes, "hd-slave")
  slave_ips = slave_ips.sort()
  
  if node['hadoop']['cluster_size'] then
    # limit the size of the cluster
    if slave_ips.length >= node['hadoop']['cluster_size']-1 then
      slave_ips = slave_ips[0 ... node['hadoop']['cluster_size']-1]
    end
  end

  secondary_ips = get_ips(all_nodes, "hd-secondary")
  
  if secondary_ips.length == 0 then
    # no secondary namenode specified, use the primary namenode
    secondary_ips.push( get_ip(node) )
  end


  template node['hadoop']['masters'] do
    source "hosts.erb"
    mode "644"
    user node['hadoop']['user']
    group node['hadoop']['group']

    variables(
      :hosts => secondary_ips
    )
  end

  template node['hadoop']['slaves'] do
    source "hosts.erb"
    mode "644"
    user node['hadoop']['user']
    group node['hadoop']['group']

    variables(
      :hosts => slave_ips
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
      :namenode_addr => get_ips(all_nodes, "hd-master")[0]
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
  options "nr_inodes=999k,mode=755,size=10240m"
  if node['hadoop']['useram']
    action [:mount, :enable]
  else
    action [:umount]
  end
end

if node['hadoop']['ganglia'] 
  template node['hadoop']['conf.dir'] + "/hadoop-metrics2.properties" do
    source "hadoop-metrics2.erb"
    user node['hadoop']['user']
    group node['hadoop']['group']

    variables(
      :ganglia_ip => node['hadoop']['ganglia']
    )
  end

  script "install gmond if needed" do
    interpreter "bash"
    user "root"
    code <<-EOH
      which gmond
      RETVAL=$?
      if [ $RETVAL -eq 1 ]; then
rpm -ivh \
http://dlutzy-pub.s3-website-us-west-1.amazonaws.com/ganglia-gmond-3.2.0-1.x86_64.rpm \
http://dlutzy-pub.s3-website-us-west-1.amazonaws.com/libganglia-3.2.0-1.x86_64.rpm \
http://dlutzy-pub.s3-website-us-west-1.amazonaws.com/libconfuse-2.6-3.el6.x86_64.rpm
      fi
    EOH
  end

  service "gmond" do
    supports :restart => true

    action [ :nothing ]
  end


  template node['hadoop']['gmond-conf'] do
    source "gmond.conf.erb"
    user "root"
    group "root"
    mode "644"
    variables(
      :host => node['hadoop']['ganglia']
    )
    
    notifies :restart, resources(:service => "gmond")
  end
end
