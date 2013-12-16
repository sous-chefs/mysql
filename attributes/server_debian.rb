#First : mysql or percona


case node['platform_family']

when 'debian'
	# Probably driven from wrapper cookbooks, environments, or roles.
	# Keep in this namespace for backwards compat
	default['mysql']['data_dir'] = '/var/lib/mysql'

	case node['mysql']['server']['type']
	when 'mysql'
		default['mysql']['server']['packages'] = %w{ mysql-server-5.5 apparmor-utils }
		default['mysql']['server']['preseed'] = 'mysql-server-5.5'
	when 'percona'
		default['mysql']['server']['packages'] = %w{  percona-server-server-5.5 percona-server-client-5.5 percona-server-common-5.5 apparmor-utils percona-nagios-plugins percona-toolkit }
		default['mysql']['server']['preseed'] = 'percona-server-server-5.5'
	when 'percona-cluster'
		default['mysql']['server']['packages'] = %w{ percona-xtradb-cluster-server-5.5 percona-xtrabackup percona-xtradb-cluster-client-5.5 percona-xtradb-cluster-common-5.5 percona-xtradb-cluster-galera-2.x apparmor-utils percona-nagios-plugins percona-toolkit }
		default['mysql']['server']['preseed'] = 'percona-server-server-5.5'
	end
	default['mysql']['server']['slow_query_log']       = 1
	default['mysql']['server']['slow_query_log_file']  = '/var/log/mysql/slow.log'

	# Platformisms.. filesystem locations and such.
	default['mysql']['server']['basedir'] = '/usr'
	default['mysql']['server']['tmpdir'] = ['/tmp']

	default['mysql']['server']['directories']['run_dir']              = '/var/run/mysqld'
	default['mysql']['server']['directories']['log_dir']              = '/var/lib/mysql'
	default['mysql']['server']['directories']['slow_log_dir']         = '/var/log/mysql'
	default['mysql']['server']['directories']['confd_dir']            = '/etc/mysql/conf.d'

	default['mysql']['server']['mysqladmin_bin']       = '/usr/bin/mysqladmin'
	default['mysql']['server']['mysql_bin']            = '/usr/bin/mysql'

	#default['mysql']['server']['pid_file']             = '/var/run/mysqld/mysqld.pid'
	default['mysql']['server']['socket']               = '/var/run/mysqld/mysqld.sock'
	default['mysql']['server']['grants_path']          = '/etc/mysql_grants.sql'
	default['mysql']['server']['old_passwords']        = 1

	# wat
	default['mysql']['tunable']['innodb_adaptive_flushing'] = false
	default['mysql']['server']['skip_federated'] = false
end
