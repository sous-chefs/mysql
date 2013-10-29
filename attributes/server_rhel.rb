case node['platform_family']    
when 'rhel', 'fedora'
  if node['mysql']['version'].to_f >= 5.5
    default['mysql']['service_name']          = 'mysql'
    default['mysql']['pid_file']              = '/var/run/mysql/mysql.pid'
  else
    default['mysql']['service_name']          = 'mysqld'
    default['mysql']['pid_file']              = '/var/run/mysqld/mysqld.pid'
  end
  default['mysql']['server']['packages']      = %w[mysql-server]
  default['mysql']['basedir']                 = '/usr'
  default['mysql']['data_dir']                = '/var/lib/mysql'
  default['mysql']['root_group']              = 'root'
  default['mysql']['mysqladmin_bin']          = '/usr/bin/mysqladmin'
  default['mysql']['mysql_bin']               = '/usr/bin/mysql'

  default['mysql']['conf_dir']                = '/etc'
  default['mysql']['confd_dir']               = '/etc/mysql/conf.d'
  default['mysql']['socket']                  = '/var/lib/mysql/mysql.sock'
  default['mysql']['old_passwords']           = 1
  default['mysql']['grants_path']             = '/etc/mysql_grants.sql'
  # RHEL/CentOS mysql package does not support this option.
  default['mysql']['tunable']['innodb_adaptive_flushing'] = false
end
