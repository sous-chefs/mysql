# frozen_string_literal: true

#
# Cookbook:: mysql
# Resource:: mysql_client_config
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
provides :mysql_client_config
unified_mode true

use '_partial/_base'

property :config_name, String, name_property: true, desired_state: false
property :options, Hash, required: true, sensitive: true, desired_state: false
property :owner, String, default: 'root', desired_state: false
property :group, String, default: 'root', desired_state: false
property :mode, String, default: '0600', desired_state: false
property :instance, String, default: 'default', desired_state: false

action :create do
  new_resource.options.each do |section, options|
    raise ArgumentError, 'Invalid MySQL option group' unless section.to_s.match?(/\A[a-zA-Z0-9_.:-]+\z/) && options.is_a?(Hash)
    raise ArgumentError, 'Invalid MySQL option name' unless options.keys.all? { |key| key.to_s.match?(/\A[a-zA-Z0-9_-]+\z/) }
  end
  directory new_resource.include_dir do
    owner new_resource.owner
    group new_resource.group
    mode '0750'
    recursive true
    action :create
    not_if { ::Dir.exist?(new_resource.include_dir) }
  end

  template "#{new_resource.include_dir}/#{new_resource.config_name}.cnf" do
    source 'client_config.cnf.erb'
    cookbook 'mysql'
    owner new_resource.owner
    group new_resource.group
    mode new_resource.mode
    sensitive true
    variables(
      config_name: new_resource.config_name,
      options: new_resource.options
    )
    action :create
  end
end

action :delete do
  file "#{new_resource.include_dir}/#{new_resource.config_name}.cnf" do
    action :delete
  end
end
