# Cookbook Name:: rackspace_mysql
# Attributes:: server_rhel
#
# Copyright 2008-2013, Opscode, Inc.
# Copyright 2014, Rackspace, US Inc.
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

case node['platform_family']
when 'rhel'
  # switching logic to account for differences in platform native
  # package versions
  case node['platform_version'].to_i
  when 6
    default['rackspace_mysql']['server']['packages'] = ['mysql-server']
    default['rackspace_mysql']['server']['slow_query_log']       = 1
    default['rackspace_mysql']['server']['slow_query_log_file']  = '/var/log/mysql/slow.log'
  end

  # Platformisms.. filesystem locations and such.
  default['rackspace_mysql']['server']['basedir'] = '/usr'
  default['rackspace_mysql']['server']['tmpdir'] = ['/tmp']

  default['rackspace_mysql']['server']['directories']['run_dir']              = '/var/run/mysqld'
  default['rackspace_mysql']['server']['directories']['log_dir']              = '/var/lib/mysql'
  default['rackspace_mysql']['server']['directories']['slow_log_dir']         = '/var/log/mysql'
  default['rackspace_mysql']['server']['directories']['confd_dir']            = '/etc/mysql/conf.d'

  default['rackspace_mysql']['server']['mysqladmin_bin']       = '/usr/bin/mysqladmin'
  default['rackspace_mysql']['server']['mysql_bin']            = '/usr/bin/mysql'

  default['rackspace_mysql']['server']['pid_file']             = '/var/run/mysqld/mysqld.pid'
  default['rackspace_mysql']['server']['socket']               = '/var/lib/mysql/mysql.sock'
  default['rackspace_mysql']['server']['grants_path']          = '/etc/mysql_grants.sql'
  default['rackspace_mysql']['server']['old_passwords']        = 1

  # RHEL/CentOS mysql package does not support this option.
  default['rackspace_mysql']['tunable']['innodb_adaptive_flushing'] = false
  default['rackspace_mysql']['server']['skip_federated'] = false
end
