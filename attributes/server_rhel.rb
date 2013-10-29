case node['platform_family']    
when 'rhel'
  
  case node['platform_version'].to_i
  when 5    
    default['mysql']['server']['packages'] = [ 'mysql-server' ]
  when 6    
    default['mysql']['server']['packages'] = [ 'mysql-server' ]
  end

  default['mysql']['server']['basedir'] = '/usr'
  default['mysql']['server']['tmpdir'] = ['/tmp']
  
  default['mysql']['server']['directories']['run_dir']              = '/var/run/mysqld'
  default['mysql']['server']['directories']['data_dir']             = '/var/lib/mysql'
  default['mysql']['server']['directories']['log_dir']              = '/var/lib/mysql'
  default['mysql']['server']['directories']['slow_log_dir']         = '/var/log/mysql'
  default['mysql']['server']['directories']['confd_dir']            = '/etc/mysql/conf.d'
  
  default['mysql']['server']['mysqladmin_bin']       = '/usr/bin/mysqladmin'  
  default['mysql']['server']['mysql_bin']            = '/usr/bin/mysql'

  default['mysql']['server']['pid_file']             = '/var/run/mysqld/mysqld.pid'
  default['mysql']['server']['socket']               = '/var/lib/mysql/mysql.sock'
  default['mysql']['server']['grants_path']          = '/etc/mysql_grants.sql'
  default['mysql']['server']['old_passwords']        = 1

  default['mysql']['server']['log_slow_queries']     = '/var/log/mysql/slow.log' # log_slow_queries is deprecated in favor of slow_query_log
  default['mysql']['server']['slow_query_log']       = '/var/log/mysql/slow.log'
   
  # RHEL/CentOS mysql package does not support this option.
  default['mysql']['tunable']['innodb_adaptive_flushing'] = false
  default['mysql']['server']['skip_federated'] = true
end
