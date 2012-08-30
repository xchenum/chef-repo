default['hadoop']['tmp.dir'] = ::File.join ::File::SEPARATOR, "mnt", "hadoop", "tmp"
default['hadoop']['conf.dir'] = ::File.join ::File::SEPARATOR, "usr", "local", "hadoop", "conf"
default['hadoop']['conf.core.site'] = ::File.join ::File::SEPARATOR, "usr", "local", "hadoop", "conf", "core-site.xml"
default['hadoop']['conf.hadoop.site'] = ::File.join ::File::SEPARATOR, "usr", "local", "hadoop", "conf", "hadoop-site.xml"
default['hadoop']['conf.hdfs.site'] = ::File.join ::File::SEPARATOR, "usr", "local", "hadoop", "conf", "hdfs-site.xml"
default['hadoop']['conf.mapred.site'] = ::File.join ::File::SEPARATOR, "usr", "local", "hadoop", "conf", "mapred-site.xml"
default['hadoop']['user'] = "hduser"
default['hadoop']['group'] = "hadoop"
default['hadoop']['replication'] = 2
default['hadoop']['useram'] = false
default['hadoop']['ramdisk.size'] = "10240m"
default['hadoop']['ramdisk'] = ::File.join ::File::SEPARATOR, "ramdisk"
default['hadoop']['masters'] = ::File.join ::File::SEPARATOR, "usr", "local", "hadoop", "conf", "masters"
default['hadoop']['slaves'] = ::File.join ::File::SEPARATOR, "usr", "local", "hadoop", "conf", "slaves"
default['hadoop']['compression'] = false
default['hadoop']['cluster_size'] = 1000
default['hadoop']['map.speculative'] = "false" 
default['hadoop']['reduce.speculative'] = "false" 
default['hadoop']['mapred.ram'] = "1024m" 
default['hadoop']['mapred.task.timeout'] = 600000
default['hadoop']['io.sort.mb'] = 500 
default['hadoop']['gmond-conf'] = ::File.join ::File::SEPARATOR, "etc", "ganglia", "gmond.conf"

