#----
# Package depends of type of mysql : mysql or percona
# Percona repo is actived for percona installation and
# remove for mysql-server installation
#---
include_recipe 'apt::default'

if (node['mysql']['server']['type'] =~ /percona/)
	#nodeip = node.attribute?('cloud') && node['cloud']['local_ipv4'] ? node['cloud']['local_ipv4'] : node['ipaddress']
	#nodeip = "gcomm://" + nodeip
	nodeip = "gcomm://"
	counter = 0
	apt_repository 'percona' do
		uri          node['mysql']['percona']['apt_uri']
		distribution node['lsb']['codename']
		components   %w[main]
		keyserver    node['mysql']['percona']['apt_keyserver']
		key          node['mysql']['percona']['apt_key_id']
		action       :add
	end

	# For check of the cluster
	package "xinetd" do
		action :install
	end

	service "xinetd" do
		service_name "xinetd"
		supports     :status => true, :restart => true, :reload => true
		action       [:enable, :start]
	end
	bash "set_service_mysqlchk" do
		user "root"
		code <<-EOF
		echo "mysqlchk		9200/tcp	# MySQL check" >> /etc/services
		EOF
		not_if "grep mysqlchk /etc/services"
		notifies :reload, 'service[xinetd]'
	end

	lbnode = search(:node, "app_server_role:#{node['haproxy']['haproxy_role']} AND chef_environment:#{node.chef_environment}").first
	template '/etc/xinetd.d/mysqlchk' do
		source 'mysqlchk.erb'
		owner 'root'
		group 'root'
		mode '0644'
		variables :lb => lbnode
		notifies :restart, 'service[xinetd]'
	end

	# We find all clusters member, regarding the cluster_name attribute
	cluster_node =  search(:node, "mysql:server AND type:percona-cluster AND chef_environment:#{node.chef_environment} AND wsrep_cluster_name:#{node["mysql"]["percona"]["tunable"]["wsrep_cluster_name"]} AND percona_cluster:enable AND NOT name:#{node['fqdn']}")
	if (node["mysql"]["percona"]["percona_cluster"] == "init")
		Chef::Log.info("Mysql : init percona cluster, next launch will enable the cluster in my.cnf file with member inside")	
		nodeip = "gcomm://"
		node.set["mysql"]["percona"]["percona_cluster"] = "enable"
	else
		# (cluster_node or []).empty?
		if (cluster_node.nil? or cluster_node == []) 
			Chef::Log.info("Mysql : alone percona server")	
			nodeip = "gcomm://"
		else
			Chef::Log.info("Mysql : percona cluster node member")	
			(cluster_node.sort).each do |n|
				localip = n.attribute?('cloud') && n['cloud']['local_ipv4'] ? n['cloud']['local_ipv4'] : n['ipaddress']
				if counter == 1
					nodeip = nodeip +','+ localip
				else
					nodeip = nodeip + localip
				end
				counter = 1
			end
		end
	end
	# We generate the line for gcomm:// will all ip of all cluster members
	node.default['mysql']['percona']['tunable']['wsrep_cluster_address'] = nodeip
else
	apt_repository 'percona' do
		uri          node['mysql']['percona']['apt_uri']
		distribution node['lsb']['codename']
		components   %w[main]
		keyserver    node['mysql']['percona']['apt_keyserver']
		key          node['mysql']['percona']['apt_key_id']
		action       :remove           
	end             
end
#----
# Set up preseeding data for debian packages
#---

seedfile = node['mysql']['server']['preseed']


directory '/var/cache/local/preseeding' do
	owner 'root'
	group 'root'
	mode '0755'
	recursive true
end

template "/var/cache/local/preseeding/#{seedfile}.seed" do
	source 'mysql-server.seed.erb'
	owner 'root'
	group 'root'
	mode '0600'
	notifies :run, 'execute[preseed mysql-server]', :immediately
end

execute 'preseed mysql-server' do
	command "/usr/bin/debconf-set-selections /var/cache/local/preseeding/#{seedfile}.seed"
	action  :nothing
end
#----
# Install software
#----
node['mysql']['server']['packages'].each do |name|
	package name do
		action :install
	end
end

node['mysql']['server']['directories'].each do |key, value|
	directory value do
		owner     'mysql'
		group     'mysql'
		mode      '0775'
		action    :create
		recursive true
	end
end

#----
# Grants
#----
template '/etc/mysql_grants.sql' do
	source 'grants.sql.erb'
	owner  'root'
	group  'root'
	mode   '0600'
	notifies :run, 'execute[install-grants]', :immediately
end

cmd = install_grants_cmd
execute 'install-grants' do
	command cmd
	action :nothing
end

#----
# data_dir
#----;

# DRAGONS!
# Setting up data_dir will only work on initial node converge...
# Data will NOT be moved around the filesystem when you change data_dir
# To do that, we'll need to stash the data_dir of the last chef-client
# run somewhere and read it. Implementing that will come in "The Future"

directory node['mysql']['data_dir'] do
	owner     'mysql'
	group     'mysql'
	action    :create
	recursive true
end

template '/etc/init/mysql.conf' do
	source 'init-mysql.conf.erb'
end

template "/root/.my.cnf" do
	source "root_my.cnf.erb"
	mode 0600
end

template '/etc/apparmor.d/usr.sbin.mysqld' do
	source 'usr.sbin.mysqld.erb'
	action :create
	notifies :reload, 'service[apparmor-mysql]', :immediately
end

service 'apparmor-mysql' do
	service_name 'apparmor'
	action :nothing
	supports :reload => true
end

template '/etc/mysql/debian.cnf' do
	source 'debian.cnf.erb'
	owner 'root'
	group 'root'
	mode '0644'
end

# We need to pass the synchro password to my.cnf
masternode = search(:node, "mysql:server AND type:percona-cluster AND chef_environment:#{node.chef_environment} AND wsrep_cluster_name:#{node['mysql']['percona']['tunable']['wsrep_cluster_name']} AND percona_cluster:enable AND percona_role:master")
if (masternode.nil? or !masternode.any?)
	xtrabackup_password = node['mysql']['server_xtrabackup_password']
else
	xtrabackup_password = masternode.first['mysql']['server_xtrabackup_password']
end

Chef::Log.info("Mysql : Retrieve Masternod #{masternode} - Passwd #{xtrabackup_password}")
template '/etc/mysql/my.cnf' do
	source 'my.cnf.erb'
	owner 'root'
	group 'root'
	mode '0644'
	variables :xtrapasswd => xtrabackup_password
	notifies :run, 'bash[move mysql data to datadir]', :immediately
	notifies :restart, 'service[mysql]', :immediately
end


# don't try this at home
# http://ubuntuforums.org/showthread.php?t=804126
bash 'move mysql data to datadir' do
	user 'root'
	code <<-EOH
  /usr/sbin/service mysql stop &&
  mv /var/lib/mysql/* #{node['mysql']['data_dir']} &&
  /usr/sbin/service mysql start
	EOH
	action :nothing
	only_if "[ '/var/lib/mysql' != #{node['mysql']['data_dir']} ]"
	only_if "[ `stat -c %h #{node['mysql']['data_dir']}` -eq 2 ]"
	not_if '[ `stat -c %h /var/lib/mysql/` -eq 2 ]'
end

service 'mysql' do
	service_name 'mysql'
	supports     :status => true, :restart => true, :reload => true
	action       [:enable, :start]
end
