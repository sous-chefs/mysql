#
# Cookbook Name:: mysql
# Recipe:: mysql_community_repo
#
# Copyright 2014, Opscode, Inc.
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

##################################################
# SHOULD THIS SHOULD BE MOVED TO ITS OWN COOKBOOK?
# A WRAPPER AROUND MYSQL THAT SETS PACKAGE NAMES?
##################################################

case node['platform_family']
when 'rhel', 'fedora'
  include_recipe 'yum::default'

  cookbook_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-mysql' do
    owner  'root'
    group  'root'
    mode   '0644'
    action :create_if_missing
  end

  yum_key 'RPM-GPG-KEY-mysql' do
    action :add
  end

  mysql_version = node['mysql']['verson'] || '5.6'
  arch = node['kernel']['machine']
  arch = 'i386' unless arch == 'x86_64'
  pversion = node['platform_version'].split('.').first
  shortcode = node['platform_family'] == 'rhel' ? 'el' : 'fc'

  yum_repository 'mysql-community' do
    repo_name   'mysql-community'
    description "MySQL #{mysql_version} Community Server"
    url         "http://repo.mysql.com/yum/mysql-#{mysql_version}-community/#{shortcode}/#{pversion}/#{arch}/"
    key         'RPM-GPG-KEY-mysql'
    action      :add
  end
end
