
client = node['chef-client-cron']['bin']
output = node['chef-client-cron']['output']

cron "chef-client" do
  minute node['chef-client-cron']['minute']
  hour node['chef-client-cron']['hour']
  user "root"
  shell "/bin/bash"

  command "/bin/sleep `/usr/bin/expr $RANDOM \\% 600`; #{client} > #{output} 2>&1"
end
