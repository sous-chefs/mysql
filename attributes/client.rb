#
# Cookbook Name:: rackspace_mysql
# Attributes:: client
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

# Include Opscode helper in Node class to get access
# to debian_before_squeeze? and ubuntu_before_lucid?
::Chef::Node.send(:include, Opscode::Mysql::Helpers)

case node['platform_family']
when 'rhel', 'fedora'
  default['rackspace_mysql']['client']['packages'] = %w[mysql mysql-devel]
when 'debian'
  if debian_before_squeeze? || ubuntu_before_lucid?
    default['rackspace_mysql']['client']['packages'] = %w[mysql-client libmysqlclient15-dev]
  else
    default['rackspace_mysql']['client']['packages'] = %w[mysql-client libmysqlclient-dev]
  end
else
  default['rackspace_mysql']['client']['packages'] = %w[mysql-client libmysqlclient-dev]
end
