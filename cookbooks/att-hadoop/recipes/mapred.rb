
def get_comp_ip(comp)
  nodes = search(:node, "chef_environment:#{node.chef_environment} AND role:" + comp) 
  if (nodes.length != 0)
    return nodes[0]["network"]["ipaddress_eth0"]
  end
  return "127.0.0.1"
end

master = get_comp_ip("hd_master")

template node['hadoop']['conf.mapred.site'] do
  source 'mapred-site.xml.erb'
  mode "644"
  owner node['hadoop']['user']
  group node['hadoop']['group']

  variables(
    :master => master
  )
end


