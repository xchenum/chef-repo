

# if node["platform"] == "centos" then
#   package "lzo-devel" do
#     action :upgrade
#   end
# else
#   package "liblzo2-dev " do
#     action :upgrade
#   end
# end

def get_ip(n)
  if n['network']
    return n['network']['ipaddress_eth0'] ||
           n['network']['ipaddress_eth1'] ||
           n['network']['ipaddress_eth2']
  else
    return nil
  end
end

def get_comp_ip(comp)
  nodes = search(:node, "chef_environment:#{node.chef_environment} AND role:" + comp) 
  if (nodes.length != 0) then
    # return nodes[0]["network"]["interfaces"]["eth0"]["addresses"].select { |address, data| data["family"] == "inet" }[0][0]
    return get_ip(nodes[0])
  end
  return "127.0.0.1"
end

def count_cpu(comp)
  res = 0
  nodes = search(:node, "chef_environment:#{node.chef_environment} AND role:" + comp) 
  nodes.each do |n|
    res = res + n['cpu']['total']
  end
  res = res + node['cpu']['total']
  return res
end

master = get_comp_ip("hd-master")
map_tasks = (search(:node, "chef_environment:#{node.chef_environment} AND role:hd-slave").length + 1) * 10
reduce_tasks = (count_cpu("hd-slave") * 1.2).to_i

template node['hadoop']['conf.mapred.site'] do
  source 'mapred-site.xml.erb'
  mode "644"
  owner node['hadoop']['user']
  group node['hadoop']['group']

  variables(
    :master => master,
    :map_tasks => map_tasks,
    :reduce_tasks => reduce_tasks,
    :map_per_node => node['cpu']['total'],
    :reduce_per_node => node['cpu']['total'] / 2,
    :compression => node['hadoop']['compression']
  )
end


