# frozen_string_literal: true

provides :mysql_service
provides :mysql_service_manager
provides :mysql_service_manager_systemd
unified_mode true

use '_partial/_base'

property :instance, String, name_property: true, regex: /\A[a-zA-Z0-9][a-zA-Z0-9_.-]*\z/, desired_state: false
property :install_method, String, equal_to: %w(auto package none), default: 'auto', desired_state: false
property :service_manager, String, equal_to: %w(auto systemd), default: 'auto', desired_state: false
property :package_name, [String, Array], default: lazy { default_server_package_name }, desired_state: false
property :package_options, [String, nil], desired_state: false
property :package_version, [String, nil], desired_state: false
property :bind_address, String, desired_state: false
property :charset, String, default: 'utf8', desired_state: false
property :data_dir, String, default: lazy { default_data_dir }, desired_state: false
property :error_log, String, default: lazy { default_error_log }, desired_state: false
property :initial_root_password, String, sensitive: true, desired_state: false
property :mysqld_options, Hash, default: {}, desired_state: false
property :pid_file, String, default: lazy { default_pid_file }, desired_state: false
property :port, [String, Integer], default: '3306', desired_state: false
property :socket, String, default: lazy { default_socket_file }, desired_state: false
property :tmp_dir, String, desired_state: false
property :mysqld_binary, String, default: '/usr/sbin/mysqld', desired_state: false
property :mysql_binary, String, default: '/usr/bin/mysql', desired_state: false
property :mysqladmin_binary, String, default: '/usr/bin/mysqladmin', desired_state: false

def socket_file(*arguments)
  socket(*arguments)
end

def lc_messages_dir; end

action :create do
  raise ArgumentError, 'mysql_service requires systemd' unless systemd?
  raise ArgumentError, 'MySQL 8.0 or newer is required' if Gem::Version.new(new_resource.version) < Gem::Version.new('8.0')
  writable_paths = [new_resource.etc_dir, new_resource.include_dir, new_resource.log_dir, new_resource.data_dir, ::File.dirname(new_resource.socket), ::File.dirname(new_resource.pid_file)].uniq
  if writable_paths.any? { |path| MysqlCookbook::Lifecycle.paths_overlap?(path, '/var/lib/chef/mysql-bootstrap') }
    raise ArgumentError, 'Instance directories must not overlap trusted MySQL bootstrap state'
  end

  ruby_block "#{new_resource.name} verify installed MySQL series" do
    block { raise 'Installed MySQL series differs from version; upgrade explicitly before converging' }
    only_if { ::File.exist?(new_resource.mysqld_binary) && !installed_series_matches? }
  end

  unless new_resource.install_method == 'none'
    mysql_server_installation new_resource.name do
      version new_resource.version
      package_name new_resource.package_name
      package_options new_resource.package_options
      package_version new_resource.package_version
    end
  end

  ruby_block "#{new_resource.name} verify selected MySQL installation" do
    block { raise 'The selected installation does not provide the requested MySQL series' }
    only_if { !::File.exist?(new_resource.mysqld_binary) || !installed_series_matches? }
  end

  group new_resource.run_group do
    system true
  end
  user new_resource.run_user do
    gid new_resource.run_group
    system true
    shell '/usr/sbin/nologin'
    manage_home false
  end

  writable_paths.each do |path|
    directory path do
      owner new_resource.run_user
      group new_resource.run_group
      mode '0750'
      recursive true
    end
  end

  template "#{new_resource.etc_dir}/my.cnf" do
    cookbook 'mysql'
    source 'my.cnf.erb'
    owner new_resource.run_user
    group new_resource.run_group
    mode '0600'
    variables(config: new_resource)
  end

  # Extend an installed vendor profile without replacing operator policy or disabling confinement.
  if ::File.exist?('/etc/apparmor.d/usr.sbin.mysqld') && ::File.exist?('/sbin/apparmor_parser')
    directory '/etc/apparmor.d/local/mysql' do
      recursive true
      mode '0755'
    end
    execute "#{new_resource.name} reload MySQL AppArmor" do
      command ['/sbin/apparmor_parser', '-r', '/etc/apparmor.d/usr.sbin.mysqld']
      action :nothing
    end
    file '/etc/apparmor.d/local/usr.sbin.mysqld' do
      content ''
      mode '0644'
      action :create_if_missing
    end
    template "/etc/apparmor.d/local/mysql/#{new_resource.mysql_name}" do
      cookbook 'mysql'
      source 'apparmor-instance.erb'
      variables(config: new_resource)
      mode '0644'
      notifies :run, "execute[#{new_resource.name} reload MySQL AppArmor]", :immediately
    end
    ruby_block "#{new_resource.name} include MySQL AppArmor instances" do
      block do
        editor = Chef::Util::FileEdit.new('/etc/apparmor.d/local/usr.sbin.mysqld')
        editor.insert_line_if_no_match(%r{^#include if exists <local/mysql>$}, '#include if exists <local/mysql>')
        editor.write_file
      end
      not_if { ::File.exist?('/etc/apparmor.d/local/usr.sbin.mysqld') && ::File.read('/etc/apparmor.d/local/usr.sbin.mysqld').include?('#include if exists <local/mysql>') }
      notifies :run, "execute[#{new_resource.name} reload MySQL AppArmor]", :immediately
    end
  end

  directory '/var/lib/chef/mysql-bootstrap' do
    owner 'root'
    group 'root'
    mode '0700'
    recursive true
  end

  ruby_block "#{new_resource.name} initialise MySQL securely" do
    block { bootstrap_database }
    sensitive true
    not_if { ::File.exist?("#{new_resource.data_dir}/mysql.ibd") && !::File.exist?(bootstrap_marker) }
  end

  systemd_unit "#{new_resource.mysql_name}.service" do
    content(
      Unit: { Description: "MySQL instance #{new_resource.instance}", After: 'network.target' },
      Service: {
        Type: 'simple', User: new_resource.run_user, Group: new_resource.run_group,
        ExecStart: "#{new_resource.mysqld_binary} --defaults-file=#{new_resource.etc_dir}/my.cnf --upgrade=NONE",
        RuntimeDirectory: new_resource.run_dir.delete_prefix('/run/'), RuntimeDirectoryMode: '0750',
        Restart: 'on-failure', TimeoutStartSec: '300', TimeoutStopSec: '300', LimitNOFILE: '65535'
      },
      Install: { WantedBy: 'multi-user.target' }
    )
    action [:create, :enable]
  end
end

[:start, :stop, :restart].each do |operation|
  action operation do
    service new_resource.mysql_name do
      action operation
    end
    unless operation == :stop
      ruby_block "#{new_resource.name} wait for MySQL readiness" do
        block do
          120.times do
            break if mysql_ready?
            sleep 0.5
          end
          raise 'MySQL did not become ready; inspect the instance error log' unless mysql_ready?
        end
        not_if { mysql_ready? }
      end
    end
  end
end

action :delete do
  raise 'Refusing to delete configuration overlapping the data directory' if MysqlCookbook::Lifecycle.paths_overlap?(new_resource.etc_dir, new_resource.data_dir)
  systemd_unit "#{new_resource.mysql_name}.service" do
    action [:stop, :disable, :delete]
    only_if { ::File.exist?("/etc/systemd/system/#{new_resource.mysql_name}.service") }
  end
  # Preserve data, shared accounts and shared packages.
  directory new_resource.etc_dir do
    recursive true
    action :delete
  end
  file "/etc/apparmor.d/local/mysql/#{new_resource.mysql_name}" do
    action :delete
    if ::File.exist?('/etc/apparmor.d/usr.sbin.mysqld') && ::File.exist?('/sbin/apparmor_parser')
      notifies :run, "execute[#{new_resource.name} remove MySQL AppArmor rules]", :delayed
    end
  end
  execute "#{new_resource.name} remove MySQL AppArmor rules" do
    command ['/sbin/apparmor_parser', '-r', '/etc/apparmor.d/usr.sbin.mysqld']
    action :nothing
  end
end

action_class do
  def mysql_ready?
    # mysqladmin ping returns success for a live server even when authentication is denied.
    shell_out(new_resource.mysqladmin_binary, '--no-defaults', '--no-login-paths', '--protocol=socket', "--socket=#{new_resource.socket}", '--user=chef-readiness', '--connect-timeout=1', 'ping', timeout: 5).exitstatus.zero?
  end

  def installed_series_matches?
    shell_out!(new_resource.mysqld_binary, '--no-defaults', '--version').stdout[/Ver\s+(\d+\.\d+)/, 1] == new_resource.major_version
  end

  def bootstrap_marker
    "/var/lib/chef/mysql-bootstrap/#{new_resource.mysql_name}.json"
  end

  def bootstrap_database
    require 'tempfile'
    fresh = !::File.exist?("#{new_resource.data_dir}/mysql.ibd")
    raise ArgumentError, 'initial_root_password must be explicitly set and non-empty for a new database' unless new_resource.property_is_set?(:initial_root_password) && !new_resource.initial_root_password.empty?
    MysqlCookbook::Lifecycle.ensure_bootstrap_marker(bootstrap_marker, data_dir: new_resource.data_dir, series: new_resource.major_version)
    if fresh
      raise 'Refusing to initialise a non-empty data directory' unless ::Dir.empty?(new_resource.data_dir)
      shell_out!(new_resource.mysqld_binary, "--defaults-file=#{new_resource.etc_dir}/my.cnf", '--initialize-insecure', user: new_resource.run_user, group: new_resource.run_group, timeout: 300)
    end
    client = MysqlCookbook::SqlClient.new({ user: 'root', password: new_resource.initial_root_password, socket: new_resource.socket }, binary: new_resource.mysql_binary)
    if !fresh && MysqlCookbook::Lifecycle.process_alive_from_pid?(new_resource.pid_file)
      # A prior bootstrap may have completed before the client or shutdown failed.
      # Authenticate before adopting it; never reset credentials on a running server.
      client.execute('SHUTDOWN')
      wait_for_bootstrap_stop
      ::File.unlink(bootstrap_marker)
      return
    end
    Tempfile.create(['chef-mysql-bootstrap-', '.sql'], new_resource.etc_dir) do |file|
      file.chmod(0600)
      file.chown(Etc.getpwnam(new_resource.run_user).uid, Etc.getgrnam(new_resource.run_group).gid)
      escapes = { '\\' => '\\\\', "'" => "\\'", "\n" => '\\n', "\r" => '\\r', "\0" => '\\0', "\u001a" => '\\Z' }
      password = new_resource.initial_root_password.gsub(/[\\'\n\r\x00\x1a]/) { |character| escapes.fetch(character) }
      file.write("SET SESSION sql_mode='';\nALTER USER 'root'@'localhost' IDENTIFIED BY '#{password}';\n")
      file.flush
      shell_out!(new_resource.mysqld_binary, "--defaults-file=#{new_resource.etc_dir}/my.cnf", '--daemonize', '--skip-networking', "--init-file=#{file.path}", user: new_resource.run_user, group: new_resource.run_group, timeout: 300)
      client.execute('SHUTDOWN')
    end
    wait_for_bootstrap_stop
    ::File.unlink(bootstrap_marker)
  rescue Mixlib::ShellOut::ShellCommandFailed, Mixlib::ShellOut::CommandTimeout
    raise 'MySQL initialisation failed; inspect the instance error log', cause: nil
  end

  def wait_for_bootstrap_stop
    300.times do
      break unless ::File.exist?(new_resource.pid_file)
      sleep 0.1
    end
    raise 'Bootstrap server did not stop' if ::File.exist?(new_resource.pid_file)
  end
end
