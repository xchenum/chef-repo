
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

all_nodes = search(:node, "chef_environment:#{node.chef_environment}")

def get_ip(n)
  if not n
    return nil
  end

  if n['network']
    return n['network']['ipaddress_eth0'] ||
           n['network']['ipaddress_eth1'] ||
           n['network']['ipaddress_eth2'] 
  else
    return nil
  end
end

def get_nodes(nodes, comp)
  res = []
  nodes.each() do |n|
    if n['roles'] and n['roles'].include?(comp)
      res.push(n)
    end
  end
  return res
end

master = get_ip( get_nodes(all_nodes, "hd-master")[0] )

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

secondary = []
get_nodes(all_nodes, "hd-secondary").each() do |n|
  secondary.push( get_ip(n) )
end

secondary_http = nil
if secondary[0] then
  secondary_http = secondary[0] + ":50090"
end  

template node['hadoop']['conf.hdfs.site'] do
  source 'hdfs-site.xml.erb'
  mode "644"
  owner node['hadoop']['user']
  group node['hadoop']['group']

  variables(
    :replication => node['hadoop']['replication'],
    :secondary_http_address => secondary_http
  )
end


