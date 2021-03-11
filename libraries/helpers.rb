module MysqlCookbook
  module HelpersBase
    require 'shellwords'

    def el7?
      return true if platform_family?('rhel') && node['platform_version'].to_i == 7
      false
    end

    def el8?
      return true if platform_family?('rhel') && node['platform_version'].to_i == 8
      false
    end

    def fedora?
      return true if platform_family?('fedora')
      false
    end

    def suse?
      return true if platform_family?('suse')
      false
    end

    def stretch?
      return true if platform?('debian') && node['platform_version'].to_i == 9
      false
    end

    def buster?
      return true if platform?('debian') && node['platform_version'].to_i == 10
      false
    end

    def xenial?
      return true if platform?('ubuntu') && node['platform_version'] == '16.04'
      false
    end

    def bionic?
      return true if platform?('ubuntu') && node['platform_version'] == '18.04'
      false
    end

    def focal?
      return true if platform?('ubuntu') && node['platform_version'] == '20.04'
      false
    end

    def defaults_file
      "#{etc_dir}/my.cnf"
    end

    def default_data_dir
      return "/var/lib/#{mysql_name}" if node['os'] == 'linux'
      return "/opt/local/lib/#{mysql_name}" if platform_family?('solaris2')
      return "/var/db/#{mysql_name}" if platform_family?('freebsd')
    end

    def default_error_log
      "#{log_dir}/error.log"
    end

    def default_pid_file
      "#{run_dir}/mysqld.pid"
    end

    def default_major_version
      # rhelish
      return '5.6' if el7?
      return '8.0' if el8?
      return '5.6' if platform?('amazon')

      # debian
      return '5.7' if stretch?
      return '8.0' if buster?

      # ubuntu
      return '5.7' if xenial?
      return '5.7' if bionic?
      return '8.0' if focal?

      # misc
      return '5.6' if platform?('freebsd')
      return '5.7' if fedora?
      return '5.6' if suse?
    end

    def major_from_full(v)
      v.split('.').shift(2).join('.')
    end

    def mysql_name
      if (defined? instance).nil? || instance == 'default'
        'mysql'
      else
        "mysql-#{instance}"
      end
    end

    def default_socket_file
      "#{run_dir}/mysqld.sock"
    end

    def default_client_package_name
      return %w(mysql mysql-devel) if el7?
      return ['mysql56', 'mysql56-devel.x86_64'] if major_version == '5.6' && platform?('amazon')
      return ['mysql57', 'mysql57-devel.x86_64'] if major_version == '5.7' && platform?('amazon')
      return ['mysql-client-5.6', 'libmysqlclient-dev'] if major_version == '5.6' && platform_family?('debian')
      return ['mysql-client-5.7', 'libmysqlclient-dev'] if major_version == '5.7' && platform_family?('debian')
      return ['mysql-client-8.0', 'libmysqlclient-dev'] if major_version == '8.0' && platform_family?('debian')
      return 'mysql-community-server-client' if major_version == '5.6' && platform_family?('suse')
      %w(mysql-community-client mysql-community-devel)
    end

    def default_server_package_name
      return 'mysql56-server' if major_version == '5.6' && platform?('amazon')
      return 'mysql57-server' if major_version == '5.7' && platform?('amazon')
      return 'mysql-server-5.6' if major_version == '5.6' && platform_family?('debian')
      return 'mysql-server-5.7' if major_version == '5.7' && platform_family?('debian')
      return 'mysql-server-8.0' if major_version == '8.0' && platform_family?('debian')
      return 'mysql-community-server' if major_version == '5.6' && platform_family?('suse')
      'mysql-community-server'
    end

    def socket_dir
      File.dirname(socket)
    end

    def run_dir
      return "#{prefix_dir}/var/run/#{mysql_name}" if platform_family?('rhel')
      return '/run/mysqld' if platform_family?('debian') && mysql_name == 'mysql'
      return "/run/#{mysql_name}" if platform_family?('debian')
      "/var/run/#{mysql_name}"
    end

    def prefix_dir
      return "/opt/mysql#{pkg_ver_string}" if platform_family?('omnios')
      return '/opt/local' if platform_family?('smartos')
      return "/opt/rh/#{scl_name}/root" if scl_package?
    end

    def scl_name
      return unless platform_family?('rhel')
    end

    def scl_package?
      return unless platform_family?('rhel')
      false
    end

    def etc_dir
      return "/opt/mysql#{pkg_ver_string}/etc/#{mysql_name}" if platform_family?('omnios')
      return "#{prefix_dir}/etc/#{mysql_name}" if platform_family?('smartos')
      "#{prefix_dir}/etc/#{mysql_name}"
    end

    def base_dir
      prefix_dir || '/usr'
    end

    def system_service_name
      return 'mysqld' if platform_family?('rhel')
      return 'mysqld' if platform_family?('fedora')
      'mysql' # not one of the above
    end

    def v56plus
      Gem::Version.new(version) >= Gem::Version.new('5.6')
    end

    def v57plus
      Gem::Version.new(version) >= Gem::Version.new('5.7')
    end

    def v80plus
      Gem::Version.new(version) >= Gem::Version.new('8.0')
    end

    def default_include_dir
      "#{etc_dir}/conf.d"
    end

    def log_dir
      return "/var/adm/log/#{mysql_name}" if platform_family?('omnios')
      "#{prefix_dir}/var/log/#{mysql_name}"
    end

    def lc_messages_dir; end

    def init_records_script
      # NOTE: shell-escaping passwords in a SQL file may cause corruption - eg
      # mysql will read \& as &, but \% as \%. Just escape bare-minimum \ and '
      sql_escaped_password = root_password.gsub('\\') { '\\\\' }.gsub("'") { '\\\'' }
      cmd = "UPDATE mysql.user SET #{password_column_name}=PASSWORD('#{sql_escaped_password}')#{password_expired} WHERE user = 'root';"
      cmd = "ALTER USER 'root'@'localhost' IDENTIFIED BY '#{sql_escaped_password}';" if v57plus

      <<-EOS
        set -e
        rm -rf /tmp/#{mysql_name}
        mkdir /tmp/#{mysql_name}
        cat > /tmp/#{mysql_name}/my.sql <<-'EOSQL'
#{cmd}
DELETE FROM mysql.user WHERE USER LIKE '';
DELETE FROM mysql.user WHERE user = 'root' and host NOT IN ('127.0.0.1', 'localhost');
FLUSH PRIVILEGES;
DELETE FROM mysql.db WHERE db LIKE 'test%';
DROP DATABASE IF EXISTS test ;
EOSQL
       #{db_init}
       #{record_init}
       while [ ! -f #{pid_file} ] ; do sleep 1 ; done
       kill `cat #{pid_file}`
       while [ -f #{pid_file} ] ; do sleep 1 ; done
       rm -rf /tmp/#{mysql_name}
      EOS
    end

    def wait_for_init
      cmd = <<-EOS
              while [ ! -f #{pid_file} ] ; do sleep 1 ; done
              kill `cat #{pid_file}`
              while [ -f #{pid_file} ] ; do sleep 1 ; done
              rm -rf /tmp/#{mysql_name}
            EOS
      cmd = '' if v57plus
      cmd
    end

    def password_column_name
      return 'authentication_string' if v57plus
      'password'
    end

    def root_password
      if initial_root_password == ''
        Chef::Log.info('Root password is empty')
        return ''
      end
      initial_root_password
    end

    def password_expired
      return ", password_expired='N'" if v57plus
      ''
    end

    def db_init
      return mysqld_initialize_cmd if v57plus
      mysql_install_db_cmd
    end

    def db_initialized?
      if v80plus
        ::File.exist? "#{data_dir}/mysql.ibd"
      else
        ::File.exist? "#{data_dir}/mysql/user.frm"
      end
    end

    def mysql_install_db_bin
      return "#{base_dir}/scripts/mysql_install_db" if platform_family?('omnios')
      return "#{prefix_dir}/bin/mysql_install_db" if platform_family?('smartos')
      'mysql_install_db'
    end

    def mysql_install_db_cmd
      cmd = mysql_install_db_bin
      cmd << " --defaults-file=#{etc_dir}/my.cnf"
      cmd << " --datadir=#{data_dir}"
      cmd << ' --explicit_defaults_for_timestamp' if v56plus && !v57plus
      return "scl enable #{scl_name} \"#{cmd}\"" if scl_package?
      cmd
    end

    def mysqladmin_bin
      return "#{prefix_dir}/bin/mysqladmin" if platform_family?('smartos')
      return 'mysqladmin' if scl_package?
      "#{prefix_dir}/usr/bin/mysqladmin"
    end

    def mysqld_bin
      return "#{prefix_dir}/libexec/mysqld" if platform_family?('smartos')
      return "#{base_dir}/bin/mysqld" if platform_family?('omnios')
      return '/usr/sbin/mysqld' if fedora? && v56plus
      return '/usr/libexec/mysqld' if fedora?
      return 'mysqld' if scl_package?
      "#{prefix_dir}/usr/sbin/mysqld"
    end

    def mysql_systemd_start_pre
      return '/usr/bin/mysqld_pre_systemd' if v57plus && (el7? || el8? || fedora?)
      return '/usr/bin/mysql-systemd-start pre' if platform_family?('rhel')
      return '/usr/lib/mysql/mysql-systemd-helper install' if suse?
      '/usr/share/mysql/mysql-systemd-start pre'
    end

    def mysql_systemd
      return "/usr/libexec/#{mysql_name}-wait-ready $MAINPID" if v57plus && (el7? || el8? || fedora?)
      return '/usr/bin/mysql-systemd-start' if platform_family?('rhel')
      return '/usr/share/mysql/mysql-systemd-start' if v57plus
      "/usr/libexec/#{mysql_name}-wait-ready $MAINPID"
    end

    def mysqld_initialize_cmd
      cmd = mysqld_bin
      cmd << " --defaults-file=#{etc_dir}/my.cnf"
      cmd << ' --initialize'
      cmd << ' --explicit_defaults_for_timestamp' if v56plus
      return "scl enable #{scl_name} \"#{cmd}\"" if scl_package?
      cmd
    end

    def mysqld_safe_bin
      return "#{prefix_dir}/bin/mysqld_safe" if platform_family?('smartos')
      return "#{base_dir}/bin/mysqld_safe" if platform_family?('omnios')
      return 'mysqld_safe' if scl_package?
      "#{prefix_dir}/usr/bin/mysqld_safe"
    end

    def record_init
      cmd = v56plus ? mysqld_bin : mysqld_safe_bin
      cmd << " --defaults-file=#{etc_dir}/my.cnf"
      cmd << " --init-file=/tmp/#{mysql_name}/my.sql"
      cmd << ' --explicit_defaults_for_timestamp' if v56plus
      cmd << ' &'
      return "scl enable #{scl_name} \"#{cmd}\"" if scl_package?
      cmd
    end

    include Chef::Mixin::ShellOut
    require 'securerandom'
    #######
    # Function to execute an SQL statement
    #   Input:
    #     query : Query could be a single String or an Array of String.
    #     database : a string containing the name of the database to query in, nil if no database choosen
    #     ctrl : a Hash which could contain:
    #        - user : String or nil
    #        - password : String or nil
    #        - host : String or nil
    #        - port : String or Integer or nil
    #        - socket : String or nil
    #   Output: A String with cmd to execute the query (but do not execute it!)
    #
    def sql_command_string(query, database, ctrl, grep_for = nil)
      raw_query = query.is_a?(String) ? query : query.join(";\n")
      Chef::Log.debug("Control Hash: [#{ctrl.to_json}]\n")
      cmd = "/usr/bin/mysql -B -e \"#{raw_query}\""
      cmd << " --user=#{ctrl[:user]}" if ctrl && ctrl.key?(:user) && !ctrl[:user].nil?
      cmd << " -p#{ctrl[:password]}"  if ctrl && ctrl.key?(:password) && !ctrl[:password].nil?
      cmd << " -h #{ctrl[:host]}"     if ctrl && ctrl.key?(:host) && !ctrl[:host].nil? && ctrl[:host] != 'localhost'
      cmd << " -P #{ctrl[:port]}"     if ctrl && ctrl.key?(:port) && !ctrl[:port].nil? && ctrl[:host] != 'localhost'
      cmd << " -S #{ctrl[:socket].nil? ? default_socket_file : ctrl[:socket]}" if ctrl && ctrl.key?(:host) && !ctrl[:host].nil? && ctrl[:host] == 'localhost'
      cmd << " #{database}"            unless database.nil?
      cmd << " | grep #{grep_for}"     if grep_for
      Chef::Log.debug("Executing this command: [#{cmd}]\n")
      cmd
    end

    #######
    # Function to execute an SQL statement in the default database.
    #   Input: Query could be a single String or an Array of String.
    #   Output: A String with <TAB>-separated columns and \n-separated rows.
    # This is easiest for 1-field (1-row, 1-col) results, otherwise
    # it will be complex to parse the results.
    def execute_sql(query, db_name, ctrl)
      cmd = shell_out(sql_command_string(query, db_name, ctrl),
                      user: 'root')
      if cmd.exitstatus != 0
        Chef::Log.fatal("mysql failed executing this SQL statement:\n#{query}")
        Chef::Log.fatal(cmd.stderr)
        raise 'SQL ERROR'
      end
      cmd.stdout
    end

    # Returns status code of sql query
    def execute_sql_exitstatus(query, ctrl)
      shell_out(sql_command_string(query, nil, ctrl), user: 'root').exitstatus
    end

    def parse_one_row(row, titles)
      return_hash = {}
      index = 0
      row.split("\t").each do |column|
        return_hash[titles[index]] = column
        index += 1
      end
      return_hash
    end

    def parse_mysql_batch_result(mysql_batch_result)
      results = mysql_batch_result.split("\n")
      titles = []
      index = 0
      return_array = []
      results.each do |row|
        if index == 0
          titles = row.split("\t")
        else
          return_array[index - 1] = parse_one_row(row, titles)
        end
        index += 1
      end
      return_array
    end
  end
end
