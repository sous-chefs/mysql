case node['platform_family']
when 'debian'
  default['mysql']['server']['packages']      = %w[mysql-server]
  default['mysql']['service_name']            = 'mysql'
  default['mysql']['basedir']                 = '/usr'
  default['mysql']['data_dir']                = '/var/lib/mysql'
  default['mysql']['root_group']              = 'root'
  default['mysql']['mysqladmin_bin']          = '/usr/bin/mysqladmin'
  default['mysql']['mysql_bin']               = '/usr/bin/mysql'

  default['mysql']['conf_dir']                    = '/etc/mysql'
  default['mysql']['confd_dir']                   = '/etc/mysql/conf.d'
  default['mysql']['socket']                      = '/var/run/mysqld/mysqld.sock'
  default['mysql']['pid_file']                    = '/var/run/mysqld/mysqld.pid'
  default['mysql']['old_passwords']               = 0
  default['mysql']['grants_path']                 = '/etc/mysql/grants.sql'
end
