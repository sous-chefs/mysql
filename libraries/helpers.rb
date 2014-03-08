module Opscode
  module Mysql
    # commands used in various recipes.
    # put here to avoid clutter
    # gain access by putting the following in your recipe:
    # ::Chef::Recipe.send(:include, Opscode::Mysql::Helpers)
    module Helpers
      def mysql_prefix
        case node['platform_family']
        when 'omnios'
          mysql_prefix = '/opt/mysql55'
        when 'smartos'
          mysql_prefix = '/opt/local'
        else
          mysql_prefix = '/usr'
        end
        mysql_prefix
      end

      def assign_root_password_cmd
        str = "#{mysql_prefix}/bin/mysqladmin"
        str << ' -u root password '
        str << node['mysql']['server_root_password']
      end

      def install_grants_cmd
        grants_file = "#{mysql_prefix}/etc/mysql_grants.sql"

        if node['mysql']['server_root_password'].empty?
          pass_string = ''
        else
          pass_string = "-p#{node['mysql']['server_root_password']}"
        end

        str = "#{mysql_prefix}/bin/mysql"
        str << ' -u root '
        str << "#{pass_string} < #{grants_file}"
      end
    end
  end
end
