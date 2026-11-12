# frozen_string_literal: true

provides :mysql_config
unified_mode true

use '_partial/_base'

property :config_name, String, name_property: true, desired_state: false
property :cookbook, String, desired_state: false
property :group, String, default: 'mysql', desired_state: false
property :instance, String, default: 'default', desired_state: false
property :owner, String, default: 'mysql', desired_state: false
property :source, String, desired_state: false
property :variables, Hash, default: {}, desired_state: false

action :create do
  group new_resource.group do
    system true
  end

  user new_resource.owner do
    gid new_resource.group
    system true
  end

  directory new_resource.include_dir do
    owner new_resource.owner
    group new_resource.group
    mode '0750'
    recursive true
  end

  template "#{new_resource.include_dir}/#{new_resource.config_name}.cnf" do
    owner new_resource.owner
    group new_resource.group
    mode '0640'
    variables new_resource.variables
    source new_resource.source if new_resource.source
    cookbook new_resource.cookbook if new_resource.cookbook
  end
end

action :delete do
  file "#{new_resource.include_dir}/#{new_resource.config_name}.cnf" do
    action :delete
  end
end
