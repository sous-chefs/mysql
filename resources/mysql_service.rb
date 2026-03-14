# frozen_string_literal: true

#
# Cookbook:: mysql
# Resource:: mysql_service
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
provides :mysql_service
unified_mode true

use '_partial/_base'
use '_partial/_service_config'

include MysqlCookbook::HelpersBase

property :package_name, String, default: lazy { default_server_package_name }, desired_state: false
property :package_options, [String, nil], desired_state: false
property :package_version, [String, nil], desired_state: false

action :create do
  # Install server package
  mysql_server_installation new_resource.name do
    version new_resource.version
    package_name new_resource.package_name
    package_version new_resource.package_version if new_resource.package_version
    package_options new_resource.package_options if new_resource.package_options
    action :install
  end

  # System user and group
  group 'mysql' do
    action :create
  end

  user 'mysql' do
    gid 'mysql'
    action :create
  end

  # Stop the system default service
  service "#{new_resource.name} stop #{system_service_name}" do
    service_name system_service_name
    provider Chef::Provider::Service::Systemd
    supports status: true
    action %i(stop disable)
  end

  # Yak shaving — remove default config files that conflict with multi-instance
  file "#{prefix_dir}/etc/my.cnf" do
    action :delete
  end

  # mysql_install_db compat link
  link "#{prefix_dir}/usr/share/my-default.cnf" do
    to "#{etc_dir}/my.cnf"
    not_if { ::File.exist? "#{prefix_dir}/usr/share/my-default.cnf" }
    action :create
  end

  # Support directories
  [etc_dir, new_resource.include_dir, log_dir, new_resource.data_dir].each do |dir|
    directory dir do
      owner new_resource.run_user
      group new_resource.run_group
      mode '0750'
      recursive true
      action :create
    end
  end

  directory run_dir do
    owner new_resource.run_user
    group new_resource.run_group
    mode '0755'
    recursive true
    action :create
  end

  # Main configuration file
  template "#{etc_dir}/my.cnf" do
    source 'my.cnf.erb'
    cookbook 'mysql'
    owner new_resource.run_user
    group new_resource.run_group
    mode '0600'
    variables(config: new_resource)
    action :create
  end

  # Initialize database and create initial records
  bash "#{new_resource.name} initial records" do
    code init_records_script
    umask '022'
    returns [0, 1, 2]
    not_if { db_initialized? }
    action :run
  end
end

action :start do
  # Needed for Debian / Ubuntu
  directory '/usr/libexec' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  # Wait-ready script called by the systemd unit
  template "/usr/libexec/#{mysql_name}-wait-ready" do
    path "/usr/libexec/#{mysql_name}-wait-ready"
    source 'systemd/mysqld-wait-ready.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables(socket_file: socket_file)
    cookbook 'mysql'
    action :create
  end

  # Main systemd unit file
  template "/etc/systemd/system/#{mysql_name}.service" do
    path "/etc/systemd/system/#{mysql_name}.service"
    source 'systemd/mysqld.service.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      config: new_resource,
      etc_dir: etc_dir,
      base_dir: base_dir,
      mysqld_bin: mysqld_bin,
      mysql_systemd_start_pre: mysql_systemd_start_pre,
      mysql_systemd: mysql_systemd
    )
    cookbook 'mysql'
    notifies :run, "execute[#{new_resource.instance} systemctl daemon-reload]", :immediately
    action :create
  end

  # Avoid 'Unit file changed on disk' warning
  execute "#{new_resource.instance} systemctl daemon-reload" do
    command '/bin/systemctl daemon-reload'
    action :nothing
  end

  # tmpfiles.d config so the service survives reboot
  template "/usr/lib/tmpfiles.d/#{mysql_name}.conf" do
    path "/usr/lib/tmpfiles.d/#{mysql_name}.conf"
    source 'tmpfiles.d.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      run_dir: run_dir,
      run_user: new_resource.run_user,
      run_group: new_resource.run_group
    )
    cookbook 'mysql'
    action :create
  end

  # Service management
  service mysql_name.to_s do
    service_name mysql_name
    provider Chef::Provider::Service::Systemd
    supports restart: true, status: true
    action %i(enable start)
  end
end

action :stop do
  service mysql_name.to_s do
    service_name mysql_name
    provider Chef::Provider::Service::Systemd
    supports status: true
    action %i(disable stop)
    only_if { ::File.exist?("/etc/systemd/system/#{mysql_name}.service") }
  end
end

action :restart do
  service mysql_name.to_s do
    service_name mysql_name
    provider Chef::Provider::Service::Systemd
    supports restart: true
    action :restart
  end
end

action :reload do
  service mysql_name.to_s do
    service_name mysql_name
    provider Chef::Provider::Service::Systemd
    action :reload
  end
end

action :delete do
  # Stop the service before removing
  service "#{new_resource.name} delete stop" do
    service_name mysql_name
    provider Chef::Provider::Service::Systemd
    supports status: true
    action %i(disable stop)
    only_if { ::File.exist?("/etc/systemd/system/#{mysql_name}.service") }
  end

  # Remove systemd unit file created by :start
  file "/etc/systemd/system/#{mysql_name}.service" do
    action :delete
  end

  # Remove wait-ready script created by :start
  file "/usr/libexec/#{mysql_name}-wait-ready" do
    action :delete
  end

  # Remove tmpfiles.d config created by :start
  file "/usr/lib/tmpfiles.d/#{mysql_name}.conf" do
    action :delete
  end

  # Remove compat link created by :create
  link "#{prefix_dir}/usr/share/my-default.cnf" do
    action :delete
    only_if { ::File.symlink?("#{prefix_dir}/usr/share/my-default.cnf") }
  end

  directory etc_dir do
    recursive true
    action :delete
  end

  directory run_dir do
    recursive true
    action :delete
  end

  directory log_dir do
    recursive true
    action :delete
  end

  # Remove server package
  mysql_server_installation new_resource.name do
    version new_resource.version
    package_name new_resource.package_name
    action :delete
  end
end

action_class do
  include MysqlCookbook::HelpersBase

  # Delegate resource properties so helpers.rb methods (init_records_script,
  # db_initialized?, etc.) can reference them without new_resource prefix.
  %i(run_user run_group data_dir error_log pid_file socket port instance version).each do |prop|
    define_method(prop) { new_resource.send(prop) }
  end

  alias_method :socket_file, :socket
end
