

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

all_nodes = search(:node, "chef_environment:#{node.chef_environment}")

def get_nodes(nodes, comp)
  res = []
  nodes.each() do |n|
    if n["roles"] and n["roles"].include?(comp)
      res.push(n)
    end
  end
  return res
end

def get_comp_ip(nodes, comp)
  res = get_nodes(nodes, comp)
  if (res.length != 0) then
    return get_ip(res[0])
  end
  return nil
end


def count_cpu(nodes, comp)
  res = 0
  get_nodes(nodes, comp).each() do |n|
    res = res + n['cpu']['total']
  end
  return res
end

master = get_comp_ip(all_nodes, "hd-master")
map_tasks = get_nodes(all_nodes, "hd-slave").length * 10
reduce_tasks = count_cpu(all_nodes, "hd-slave") 

template node['hadoop']['conf.mapred.site'] do
  source 'mapred-site.xml.erb'
  mode "644"
  owner node['hadoop']['user']
  group node['hadoop']['group']

  variables(
    :master => master,
    #:map_tasks => map_tasks,
    :map_tasks => reduce_tasks,
    #:reduce_tasks => reduce_tasks,
    :reduce_tasks => reduce_tasks,
    :map_per_node => node['cpu']['total'],
    :reduce_per_node => node['cpu']['total'] / 2,
    :compression => node['hadoop']['compression']
  )
end


