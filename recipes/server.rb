#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2008-2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
::Chef::Recipe.send(:include, Opscode::Mysql::Helpers)

if Chef::Config[:solo]
	missing_attrs = %w[
    server_debian_password
    server_root_password
    server_repl_password
    server_dbbackup_password
    server_xtrabackup_password
	].select { |attr| node['mysql'][attr].nil? }.map { |attr| %Q{node['mysql']['#{attr}']} }

	unless missing_attrs.empty?
		Chef::Application.fatal! "You must set #{missing_attrs.join(', ')} in chef-solo mode." \
			" For more information, see https://github.com/opscode-cookbooks/mysql#chef-solo-note"
	end
else
	if ( node["mysql"]["server"]["type"] == "percona-cluster" )
		Chef::Log.info("Mysql : Percona-cluster")
		if  ( node["mysql"]["percona"]["percona_role"] == "master" )
			# First member of the cluster
			Chef::Log.info("Mysql : Percona-cluster Master")
			node.set_unless['mysql']['server_xtrabackup_password'] = secure_password
			node.set_unless['mysql']['percona']['tunable']['server_id']= "0"
			node.save
		else
			# A new member of an existing cluster
			Chef::Log.info("Mysql : Percona-cluster new member")
			
			# Determine it's server id
			membernode = search(:node, "mysql:server AND type:percona-cluster AND chef_environment:#{node.chef_environment} AND wsrep_cluster_name:#{node['mysql']['percona']['tunable']['wsrep_cluster_name']} AND percona_cluster:enable AND NOT percona_role:master").sort
			if ((membernode or []).empty?)
				Chef::Log.info("Mysql : Percona-cluster first member")
				node.set_unless['mysql']['percona']['tunable']['server_id']= "1"
			else
				id=membernode.length+1
				Chef::Log.info("Mysql : Percona-cluster member number #{id}")
				node.set_unless['mysql']['percona']['tunable']['server_id']= "#{id}"
			end

			# Determine masternode if exist to retrieve its parameters
			masternode = search(:node, "mysql:server AND type:percona-cluster AND chef_environment:#{node.chef_environment} AND wsrep_cluster_name:#{node['mysql']['percona']['tunable']['wsrep_cluster_name']} AND percona_cluster:enable AND percona_role:master")
			if masternode.nil?
				Chef::Log.info("Mysql : masternode doesn't exist yet")
			else
				Chef::Log.info("Mysql : masternode found, password are setup accordingly")
				masternode.each do |n|
					password = n['mysql']['server_xtrabackup_password']
					node.set_unless['mysql']['server_xtrabackup_password'] = password
					password = n['mysql']['server_root_password']
					node.set_unless['mysql']['server_root_password'] = password
					password = n['mysql']['server_repl_password']
					node.set_unless['mysql']['server_repl_password'] = password
					password = n['mysql']['server_dbbackup_password']
					node.set_unless['mysql']['server_dbbackup_password'] = password
					node.save
				end
			end
		end
	end
	Chef::Log.info("Mysql : We generate all password if not yet defined")
	# generate all passwords
	node.set_unless['mysql']['server_debian_password'] = secure_password
	node.set_unless['mysql']['server_root_password']   = secure_password
	node.set_unless['mysql']['server_repl_password']   = secure_password
	node.set_unless['mysql']['server_dbbackup_password']   = secure_password
	node.save
end

localip =  node.attribute?('cloud') && node['cloud']['local_ipv4'] ? node['cloud']['local_ipv4'] : node['ipaddress']
# A server need client packages
case node['mysql']['server']['type']
when 'mysql'
	node.set['mysql']['client']['type'] = "mysql"
when 'percona'
	node.set['mysql']['client']['type'] = "percona"
when 'percona-cluster'
	node.set['mysql']['client']['type'] = "percona-cluster"
	node.set['mysql']['percona']['tunable']['wsrep_provider_options']="\"gmcast.listen_addr=tcp://#{localip};ist.recv_addr=#{localip};\""
end


case node['platform_family']
when 'rhel'
	include_recipe 'mysql::_server_rhel'
when 'debian'
	include_recipe 'mysql::_server_debian'
when 'mac_os_x'
	include_recipe 'mysql::_server_mac_os_x'
when 'windows'
	include_recipe 'mysql::_server_windows'
end
