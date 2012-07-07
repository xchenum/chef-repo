default['hadoop']['tmp.dir'] = ::File.join ::File::SEPARATOR, "mnt", "hadoop", "tmp"
default['hadoop']['conf.core.site'] = ::File.join ::File::SEPARATOR, "usr", "local", "hadoop", "conf", "core-site.xml"
default['hadoop']['conf.hdfs.site'] = ::File.join ::File::SEPARATOR, "usr", "local", "hadoop", "conf", "hdfs-site.xml"
default['hadoop']['conf.mapred.site'] = ::File.join ::File::SEPARATOR, "usr", "local", "hadoop", "conf", "mapred-site.xml"
default['hadoop']['user'] = "hduser"
default['hadoop']['group'] = "hadoop"
default['hadoop']['replication'] = 2

