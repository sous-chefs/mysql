if 'freebsd' == node['platform_family']
  default['mysql']['data_dir']                 = '/var/db/mysql'
  default['mysql']['conf_dir']                 = '/usr/local/etc'

  default['mysql']['server']['directories']['confd_dir']    = '/usr/local/etc/mysql/conf.d'
  default['mysql']['server']['directories']['log_dir']      = '/var/lib/mysql'
  default['mysql']['server']['directories']['slow_log_dir'] = '/var/log/mysql'

  default['mysql']['server']['slow_query_log']      = false
  default['mysql']['server']['slow_query_log_file'] = '/var/log/mysql/slow.log'
  default['mysql']['server']['packages']       = %w[mysql55-server]
  default['mysql']['server']['service_name']   = 'mysql-server'
  default['mysql']['server']['basedir']        = '/usr/local'
  default['mysql']['server']['tmpdir']         = ['/tmp']
  default['mysql']['server']['root_group']     = node['root_group']
  default['mysql']['server']['mysqladmin_bin'] = '/usr/local/bin/mysqladmin'
  default['mysql']['server']['mysql_bin']      = '/usr/local/bin/mysql'
  default['mysql']['server']['socket']         = '/tmp/mysqld.sock'
  default['mysql']['server']['pid_file']       = '/var/db/mysql/mysqld.pid'
  default['mysql']['server']['old_passwords']  = 0
  default['mysql']['server']['grants_path']    = '/var/db/mysql/grants.sql'
  default['mysql']['server']['skip_federated'] = false
end
