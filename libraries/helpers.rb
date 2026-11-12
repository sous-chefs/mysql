# frozen_string_literal: true

module MysqlCookbook
  module HelpersBase
    def mysql_name
      !respond_to?(:instance) || instance == 'default' ? 'mysql' : "mysql-#{instance}"
    end

    def etc_dir
      "/etc/#{mysql_name}"
    end

    def log_dir
      "/var/log/#{mysql_name}"
    end

    def run_dir
      platform_family?('debian') && mysql_name == 'mysql' ? '/run/mysqld' : "/run/#{mysql_name}"
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

    def default_socket_file
      "#{run_dir}/mysqld.sock"
    end

    def default_include_dir
      "#{etc_dir}/conf.d"
    end

    def default_client_package_name
      platform_family?('debian') ? %w(mysql-community-client libmysqlclient-dev) : %w(mysql-community-client mysql-community-devel)
    end

    def default_server_package_name
      'mysql-community-server'
    end
  end
end
