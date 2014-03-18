module Opscode
  module Mysql
    module Helpers
      class MysqlPackageMap
        def self.mysql_package_map
          @mysql_package_map ||= {
            'rhel' => {
              '5' => {
                'default_version' => '5.0',
                '5.0' => 'mysql-server',
                '5.1' => 'mysql51-mysql-server',
                '5.5' => 'mysql55-mysql-server'
              },
              '6' => {
                'default_version' => '5.1',
                '5.1' => 'mysql-server'
              }
            },
            'amazon' => {
              '2013.09' => {
                'default_version' => '5.1',
                '5.1' => 'mysql-server'
              }
            },
            'fedora' => {
              '19' => {
                'default_version' => '5.1',
                '5.1' => 'community-mysql-server'
              }
            },
            'debian' => {
              '7' => {
                'default_version' => '5.5',
                '5.5' => 'mysql-server-5.5'
              }
            },
            'ubuntu' => {
              '10.04' => {
                'default_version' => '5.1',
                '5.1' => 'mysql-server-5.1'
              },
              '12.04' => {
                'default_version' => '5.5',
                '5.5' => 'mysql-server-5.5'
              },
              '13.10' => {
                'default_version' => '5.5',
                '5.5' => 'mysql-server-5.5'
              }
            },
            'smartos' => {
              '1303' => {
                'default_version' => '5.5',
                '5.5' => 'mysql-server-5.5',
                '5.6' => 'mysql-server-5.6'
              }
            },
            'omnios' => {
              '151006' => {
                'default_version' => '5.5',
                '5.5' => 'database/mysql-55',
                '5.6' => 'database/mysql-56'
              }
            }
          }
        end

        def self.default_version_for(platform, platform_version, mysql_version)
          MysqlPackageMap.mysql_package_map[platform][platform_version]['default_version']
        rescue NoMethodError
          nil
        end

        def self.package_for(platform, platform_version, mysql_version)
          MysqlPackageMap.mysql_package_map[platform][platform_version][mysql_version]
        rescue NoMethodError
          nil
        end

        def self.lookup_version(platform, platform_version, mysql_version)
          return mysql_version unless mysql_version.nil?
          MysqlPackageMap.default_version_for(platform, platform_version, mysql_version)
        end
      end
    end
  end
end
