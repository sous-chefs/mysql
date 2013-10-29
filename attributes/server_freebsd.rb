case node['platform_family']
  
when 'freebsd'
  default['mysql']['server']['packages']      = %w[mysql55-server]
  default['mysql']['service_name']            = 'mysql-server'
  default['mysql']['basedir']                 = '/usr/local'
  default['mysql']['data_dir']                = '/var/db/mysql'
  default['mysql']['root_group']              = 'wheel'
  default['mysql']['mysqladmin_bin']          = '/usr/local/bin/mysqladmin'
  default['mysql']['mysql_bin']               = '/usr/local/bin/mysql'
  default['mysql']['conf_dir']                = '/usr/local/etc'
  default['mysql']['confd_dir']               = '/usr/local/etc/mysql/conf.d'
  default['mysql']['socket']                  = '/tmp/mysqld.sock'
  default['mysql']['pid_file']                = '/var/run/mysqld/mysqld.pid'
  default['mysql']['old_passwords']           = 0
  default['mysql']['grants_path']             = '/var/db/mysql/grants.sql'
end

