
tmp_dir = ""

if node['hadoop']['useram'] then
  tmp_dir = node['hadoop']['ramdisk'] + "/hadoop/tmp"
else
  tmp_dir = node['hadoop']['tmp.dir']
end

directory tmp_dir  do
  owner "hduser"
  group "hadoop"
  mode "750"
  action :create
  recursive true
end

def get_comp_ip(comp)
  nodes = search(:node, "chef_environment:#{node.chef_environment} AND role:" + comp) 
  if (nodes.length != 0) then
    return (nodes[0]['network']['ipaddress_eth0'] || nodes[0]['network']['ipaddress_eth1'])
  end
  return "127.0.0.1"
end

master = get_comp_ip("hd-master")

template node['hadoop']['conf.core.site'] do
  source 'core-site.xml.erb'
  mode "644"
  owner node['hadoop']['user']
  group node['hadoop']['group']

  variables(
    :tmp_dir    => tmp_dir,
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


