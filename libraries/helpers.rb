module Opscode
  module Mysql
    module Helpers
      class MysqlPackageMap
        def self.mysql_package_map
          @mysql_package_map ||= {
            'rhel' => {
              '5' => {
                '5.0' => 'mysql-server',
                '5.1' => 'mysql51-mysql-server',
                '5.5' => 'mysql55-mysql-server'
              },
              '6' => {
                '5.1' => 'mysql-server'
              }
            },
            'amazon' => {
              '2013.09' => {
                '5.1' => 'mysql-server'
              }
            },
            'fedora' => {
              '19' => {
                '5.1' => 'community-mysql-server'
              }
            },
            'debian' => {
              '7' => {
                '5.5' => 'mysql-server-5.5'
              }
            },
            'ubuntu' => {
              '10.04' => {
                '5.1' => 'mysql-server-5.1'
              },
              '12.04' => {
                '5.5' => 'mysql-server-5.5'
              },
              '13.10' => {
                '5.5' => 'mysql-server-5.5'
              }
            },
            'smartos' => {
              '1303' => {
                '5.5' => 'mysql-server-5.5',
                '5.6' => 'mysql-server-5.6'
              }
            },
            'omnios' => {
              '151006' => {
                '5.5' => 'mysql-55',
                '5.6' => 'mysql-56'
              }
            }
          }
        end

        def self.package_for(platform, platform_version, mysql_version)
          MysqlPackageMap.mysql_package_map[platform][platform_version][mysql_version]
        end
      end
    end
  end
end
