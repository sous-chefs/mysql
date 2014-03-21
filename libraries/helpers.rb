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
                'default_version' => '5.5',
                '5.5' => 'community-mysql-server'
              },
              '20' => {
                'default_version' => '5.5',
                '5.5' => 'community-mysql-server'
              }
            },
            'debian' => {
              '7.0' => {
                'default_version' => '5.5',
                '5.5' => 'mysql-server-5.5'
              },
              '7.1' => {
                'default_version' => '5.5',
                '5.5' => 'mysql-server-5.5'
              },
              '7.2' => {
                'default_version' => '5.5',
                '5.5' => 'mysql-server-5.5'
              },
              '7.3' => {
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
              # Do this or now, until Ohai correctly detects a
              # smartmachine vs global zone (base64 13.4.0) from /etc/product
              '5.11' => {
                'default_version' => '5.5',
                '5.5' => 'mysql-server',
                '5.6' => 'mysql-server'
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

      class MysqlDatadir
        def self.mysql_datadir_map
          @mysql_datadir_map ||= {
            'rhel' => '/var/lib/mysql',
            'amazon' => '/var/lib/mysql',
            'fedora' => '/var/lib/mysql',
            'debian' => '/var/lib/mysql',
            'ubuntu' => '/var/lib/mysql',
            'smartos' => '/opt/local/lib/mysql',
            'omnios' => '/var/lib/mysql'
          }
        end
      end
    end
  end
end
