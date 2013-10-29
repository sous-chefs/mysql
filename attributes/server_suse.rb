case node['platform_family'] 
when 'suse'
  default['mysql']['service_name']            = 'mysql'
  default['mysql']['server']['packages']      = %w[mysql-community-server]
  default['mysql']['basedir']                 = '/usr'
  default['mysql']['data_dir']                = '/var/lib/mysql'
  default['mysql']['root_group']              = 'root'
  default['mysql']['mysqladmin_bin']          = '/usr/bin/mysqladmin'
  default['mysql']['mysql_bin']               = '/usr/bin/mysql'
  default['mysql']['conf_dir']                = '/etc'
  default['mysql']['confd_dir']               = '/etc/mysql/conf.d'
  default['mysql']['socket']                  = '/var/run/mysql/mysql.sock'
  default['mysql']['pid_file']                = '/var/run/mysql/mysqld.pid'
  default['mysql']['old_passwords']           = 1
  default['mysql']['grants_path']             = '/etc/mysql_grants.sql'
end
