#
# Cookbook Name:: mysql
# Recipe:: ruby
#
# Author:: Jesse Howarth (<him@jessehowarth.com>)
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#
# Copyright 2008-2014, Opscode, Inc.
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

node.set['build_essential']['compiletime'] = true
include_recipe 'build-essential::default'
include_recipe 'mysql::client'

loaded_recipes = if run_context.respond_to?(:loaded_recipes)
                   run_context.loaded_recipes
                 else
                   node.run_state[:seen_recipes]
                 end

if loaded_recipes.include?('mysql::percona_repo')
  case node['platform_family']
  when 'debian'
    resources('apt_repository[percona]').run_action(:add)
  when 'rhel'
    resources('yum_key[RPM-GPG-KEY-percona]').run_action(:add)
    resources('yum_repository[percona]').run_action(:add)
  end
end

if loaded_recipes.include?('mysql::mysql_community_repo')
  case node['platform_family']
  when 'rhel', 'fedora'
    resources('cookbook_file[/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql]').run_action(:create_if_missing)
    resources('yum_key[RPM-GPG-KEY-mysql]').run_action(:add)
    resources('yum_repository[mysql-community]').run_action(:add)
    # Workaround for https://tickets.opscode.com/browse/COOK-4312 until we upgrade
    # to yum 3.x
    begin
      resources('template[/etc/yum.repos.d/mysql-community.repo]').run_action(:create)
    rescue Chef::Exceptions::ResourceNotFound
    end
  end
end

node['mysql']['client']['packages'].each do |name|
  resources("package[#{name}]").run_action(:install)
end

chef_gem 'mysql'
