

directory node['hadoop']['tmp.dir'] do
  owner "hduser"
  group "hadoop"
  mode "750"
  action :create
  recursive true
end

def get_comp_ip(comp)
  nodes = search(:node, "chef_environment:#{node.chef_environment} AND role:" + comp) 
  if (nodes.length != 0)
    return nodes[0]["network"]["ipaddress_eth0"]
  end
  return "127.0.0.1"
end

master = get_comp_ip("hd_master")

template node['hadoop']['conf.core.site'] do
  source 'core-site.xml.erb'
  mode "644"
  owner node['hadoop']['user']
  group node['hadoop']['group']

  variables(
    :tmp_dir    => node['hadoop']['tmp.dir'],
    :name_node  => master
  )
end

template node['hadoop']['conf.hdfs.site'] do
  source 'hdfs-site.xml.erb'
  mode "644"
  owner node['hadoop']['user']
  group node['hadoop']['group']

  variables(
    :replication => node['hadoop']['replication']
  )
end


