
def get_comp_ip(comp)
  nodes = search(:node, "chef_environment:#{node.chef_environment} AND role:" + comp) 
  if (nodes.length != 0)
    return nodes[0]["network"]["interfaces"]["eth0"]["addresses"].select { |address, data| data["family"] == "inet" }[0][0]
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
reduce_tasks = count_cpu("hd-slave") * 2

template node['hadoop']['conf.mapred.site'] do
  source 'mapred-site.xml.erb'
  mode "644"
  owner node['hadoop']['user']
  group node['hadoop']['group']

  variables(
    :master => master,
    :map_tasks => map_tasks,
    :reduce_tasks => reduce_tasks,
    :map_per_node => node['cpu']['total'] * 2,
    :reduce_per_node => node['cpu']['total'] / 2
  )
end


