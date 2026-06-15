# frozen_string_literal: true

module MysqlCookbook
  module HelpersBase
    require 'shellwords'

    def el8?
      return true if platform_family?('rhel') && node['platform_version'].to_i == 8

      false
    end

    def el9?
      return true if platform_family?('rhel') && node['platform_version'].to_i == 9

      false
    end

    def el10?
      return true if platform_family?('rhel') && node['platform_version'].to_i == 10

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

    def focal?
      return true if platform?('ubuntu') && node['platform_version'] == '20.04'

      false
    end

    def jammy?
      return true if platform?('ubuntu') && node['platform_version'] == '22.04'

      false
    end

    def noble?
      return true if platform?('ubuntu') && node['platform_version'] == '24.04'

      false
    end

    def defaults_file
      "#{etc_dir}/my.cnf"
    end

    def default_data_dir
      "/var/lib/#{mysql_name}"
    end

    def default_error_log
      "#{log_dir}/error.log"
    end

    def default_pid_file
      "#{run_dir}/mysqld.pid"
    end

    def default_major_version
      # EL family
      return '8.0' if el8?
      return '8.0' if el9?
      return '8.4' if el10?

      # Amazon Linux
      return '8.4' if platform?('amazon')

      # Debian
      return '8.0' if platform?('debian') && node['platform_version'].to_i == 12
      return '8.4' if platform?('debian') && node['platform_version'].to_i >= 13

      # Ubuntu
      return '8.0' if focal?
      return '8.0' if jammy?
      return '8.0' if noble?

      # Fedora
      return '8.4' if fedora?

      # SUSE
      return '8.4' if suse?

      '8.4'
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
      # Debian ships MariaDB as default; use distro compat packages
      if platform?('debian') && node['platform_version'].to_i >= 12
        return %w(default-mysql-client libmariadb-dev-compat)
      end

      # Ubuntu ships MySQL packages with version suffix
      return ["mysql-client-#{major_version}", 'libmysqlclient-dev'] if platform_family?('debian')

      # RHEL, Fedora, Amazon, SUSE all use MySQL community packages
      %w(mysql-community-client mysql-community-devel)
    end

    def default_server_package_name
      # Debian 12+ uses MySQL community repo packages
      return 'mysql-community-server' if platform?('debian') && node['platform_version'].to_i >= 12

      # Ubuntu ships MySQL packages with version suffix
      return "mysql-server-#{major_version}" if platform_family?('debian')

      # RHEL, Fedora, Amazon, SUSE all use MySQL community packages
      'mysql-community-server'
    end

    def socket_dir
      File.dirname(socket)
    end

    def run_dir
      return "/var/run/#{mysql_name}" if platform_family?('rhel', 'fedora', 'amazon', 'suse')
      return '/run/mysqld' if platform_family?('debian') && mysql_name == 'mysql'
      return "/run/#{mysql_name}" if platform_family?('debian')

      "/var/run/#{mysql_name}"
    end

    def etc_dir
      "/etc/#{mysql_name}"
    end

    def base_dir
      '/usr'
    end

    def system_service_name
      return 'mysqld' if platform_family?('rhel')
      return 'mysqld' if platform_family?('fedora')

      'mysql' # not one of the above
    end

    def v80plus
      Gem::Version.new(version) >= Gem::Version.new('8.0')
    end

    def default_include_dir
      "#{etc_dir}/conf.d"
    end

    def log_dir
      "/var/log/#{mysql_name}"
    end

    def init_records_script
      # MySQL 8.x --initialize (secure) generates a random temporary password
      # for root@localhost and logs it to the error log. We capture it, start
      # mysqld, change the expired temp password to a permanent one (which is
      # the captured password itself), and save it to a file on disk.
      <<~EOS
        set -e
        rm -rf /tmp/#{mysql_name}
        mkdir /tmp/#{mysql_name}

        #{mysqld_bin} --defaults-file=#{etc_dir}/my.cnf --initialize --user=#{run_user}

        TEMP_PASS=$(grep 'temporary password' #{error_log} | tail -1 | awk '{print $NF}')
        if [ -z "$TEMP_PASS" ]; then
          echo "ERROR: Could not capture temporary password from #{error_log}" >&2
          exit 1
        fi

        cat > /tmp/#{mysql_name}/temp.cnf << EOCNF
        [client]
        user=root
        password="$TEMP_PASS"
        EOCNF
        chmod 600 /tmp/#{mysql_name}/temp.cnf

        #{mysqld_bin} --defaults-file=#{etc_dir}/my.cnf --user=#{run_user} &
        while [ ! -f #{pid_file} ] ; do sleep 1 ; done
        sleep 5

        PERM_PASS="$TEMP_PASS"
        /usr/bin/mysql --defaults-extra-file=/tmp/#{mysql_name}/temp.cnf -S #{default_socket_file} --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$PERM_PASS';"

        printf '%s' "$PERM_PASS" > #{etc_dir}/.root_password
        chmod 600 #{etc_dir}/.root_password

        kill $(cat #{pid_file}) || true
        while [ -f #{pid_file} ] ; do sleep 1 ; done
        rm -rf /tmp/#{mysql_name}
      EOS
    end

    def password_column_name
      'authentication_string'
    end

    def root_password
      password_file = "#{etc_dir}/.root_password"
      if ::File.exist?(password_file)
        return ::File.read(password_file).strip
      end

      ''
    end

    def db_init
      mysqld_initialize_cmd
    end

    def db_initialized?
      ::File.exist? "#{data_dir}/mysql.ibd"
    end

    def mysqladmin_bin
      '/usr/bin/mysqladmin'
    end

    def mysqld_bin
      '/usr/sbin/mysqld'
    end

    def mysql_systemd_start_pre
      return '/usr/bin/mysqld_pre_systemd' if platform_family?('rhel', 'fedora', 'amazon')
      return '/usr/lib/mysql/mysql-systemd-helper install' if suse?

      '/usr/share/mysql/mysql-systemd-start pre'
    end

    def mysql_systemd
      return "/usr/libexec/#{mysql_name}-wait-ready $MAINPID" if platform_family?('rhel', 'fedora', 'amazon')

      "/usr/libexec/#{mysql_name}-wait-ready $MAINPID"
    end

    def mysqld_initialize_cmd
      cmd = mysqld_bin
      cmd << " --defaults-file=#{etc_dir}/my.cnf"
      cmd << ' --initialize'
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
      cmd << " --user=#{ctrl[:user]}" if ctrl&.key?(:user) && !ctrl[:user].nil?
      cmd << " -p#{Shellwords.escape(ctrl[:password])}" if ctrl&.key?(:password) && !ctrl[:password].nil?
      cmd << " -h #{ctrl[:host]}"     if ctrl&.key?(:host) && !ctrl[:host].nil? && ctrl[:host] != 'localhost'
      cmd << " -P #{ctrl[:port]}"     if ctrl&.key?(:port) && !ctrl[:port].nil? && ctrl[:host] != 'localhost'
      if ctrl&.key?(:host) && !ctrl[:host].nil? && ctrl[:host] == 'localhost'
        cmd << " -S #{ctrl[:socket].nil? ? default_socket_file : ctrl[:socket]}"
      end
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
        if index.zero?
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
