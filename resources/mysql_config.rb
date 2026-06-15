# frozen_string_literal: true

#
# Cookbook:: mysql
# Resource:: mysql_config
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
provides :mysql_config
unified_mode true

use '_partial/_base'

include MysqlCookbook::HelpersBase

property :config_name, String, name_property: true, desired_state: false
property :cookbook, String, desired_state: false
property :group, String, default: 'mysql', desired_state: false
property :instance, String, default: 'default', desired_state: false
property :owner, String, default: 'mysql', desired_state: false
property :source, String, desired_state: false
property :variables, [Hash], desired_state: false

action :create do
  group new_resource.group do
    system true if new_resource.group == 'mysql'
    action :create
  end

  user new_resource.owner do
    gid new_resource.owner
    system true if new_resource.owner == 'mysql'
    action :create
  end

  directory new_resource.include_dir do
    owner new_resource.owner
    group new_resource.group
    mode '0750'
    recursive true
    action :create
  end

  template "#{new_resource.include_dir}/#{new_resource.config_name}.cnf" do
    owner new_resource.owner
    group new_resource.group
    mode '0640'
    variables(new_resource.variables)
    source new_resource.source
    cookbook new_resource.cookbook
    action :create
  end
end

action :delete do
  file "#{new_resource.include_dir}/#{new_resource.config_name}.cnf" do
    action :delete
  end
end
