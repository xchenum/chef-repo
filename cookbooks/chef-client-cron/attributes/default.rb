default['chef-client-cron']['bin'] = ::File.join ::File::SEPARATOR, "usr", "local", "bin", "chef-client"
default['chef-client-cron']['output'] = ::File.join ::File::SEPARATOR, "tmp", "chef-client.out"
default['chef-client-cron']['hour'] = "*"
default['chef-client-cron']['minute'] = "0,30"
