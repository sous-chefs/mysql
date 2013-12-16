if ( node['mysql']['server']['type'] == "percona-cluster" )
default['mysql']['percona']['tunable']['wsrep_provider'] = '/usr/lib/libgalera_smm.so'
#default['mysql']['percona']['tunable']['wsrep_cluster_address'] = 'gcomm://'
default['mysql']['percona']['tunable']['wsrep_sst_method']	='xtrabackup'
default['mysql']['percona']['tunable']['wsrep_cluster_name']	='tosetmanually'
default['mysql']['percona']['tunable']['wsrep_node_name']	= node['hostname']
default['mysql']['percona']['tunable']['wsrep_node_address']	= node.attribute?('cloud') && node['cloud']['local_ipv4'] ? node['cloud']['local_ipv4'] : node['ipaddress']
default['mysql']['percona']['tunable']['binlog_format']		='ROW'
default['mysql']['percona']['tunable']['default_storage_engine']='InnoDB'
default['mysql']['percona']['tunable']['innodb_autoinc_lock_mode']='2'
default['mysql']['percona']['tunable']['innodb_locks_unsafe_for_binlog']='1'
default['mysql']['percona']['tunable']['#wsrep_replicate_myisam']='1'
default['mysql']['percona']['tunable']['wait_timeout']	='7000'
default['mysql']['percona']['percona_cluster'] = 'enable'
end
