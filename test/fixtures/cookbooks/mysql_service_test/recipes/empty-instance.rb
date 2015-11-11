    mysql_service 'default' do
      port '3306'
      version '5.7'
      initial_root_password "ilikerandompasswords"
      data_dir '/var/lib/mysql'
      instance ''
      action [:create, :start]
      if node['platform_family'] == 'debian'
        socket '/var/run/mysqld/mysqld.sock'
      else
        socket '/var/lib/mysql/mysql.sock'
      end
    end

