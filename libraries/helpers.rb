module Opscode
  module Mysql
    module Helpers
      def default_version_for(platform, platform_family, platform_version)
        keyname = keyname_for(platform, platform_family, platform_version)
        PlatformInfo.mysql_info[platform_family][keyname]['default_version']
      rescue NoMethodError
        nil
      end

      def package_name_for(platform, platform_family, platform_version, version)
        keyname = keyname_for(platform, platform_family, platform_version)
        PlatformInfo.mysql_info[platform_family][keyname][version]
      rescue NoMethodError
        nil
      end

      def default_data_dir_for(platform_family)
        PlatformInfo.mysql_info[platform_family]['default_data_dir']
      rescue NoMethodError
        nil
      end

      def keyname_for(platform, platform_family, platform_version)
        case
        when platform_family == 'rhel'
          platform == 'amazon' ? platform_version : platform_version.to_i.to_s
        when platform_family == 'fedora'
          platform_version
        when platform_family == 'debian'
          platform == 'ubuntu' ? platform_version : platform_version.to_i.to_s
        when platform_family == 'smartos'
          platform_version
        when platform_family == 'omnios'
          platform_version
        end
      rescue NoMethodError
        nil
      end
    end

    class PlatformInfo
      def self.mysql_info
        @mysql_info ||= {
          'rhel' => {
            'default_data_dir' => '/var/lib/mysql',
            '5' => {
              'default_version' => '5.0',
              '5.0' => 'mysql-server',
              '5.1' => 'mysql51-mysql-server',
              '5.5' => 'mysql55-mysql-server'
            },
            '6' => {
              'default_version' => '5.1',
              '5.1' => 'mysql-server'
            },
            '7' => {
              'default_version' => '5.5',
              '5.1' => 'mysql51-server',
              '5.5' => 'mysql55-server'
            },
            '2013.09' => {
              'default_version' => '5.1',
              '5.1' => 'mysql-server'
            },
            '2014.03' => {
              'default_version' => '5.5',
              '5.1' => 'mysql51-server',
              '5.5' => 'mysql55-server'
            }
          },
          'fedora' => {
            'default_data_dir' => '/var/lib/mysql',
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
            'default_data_dir' => '/var/lib/mysql',
            '7' => {
              'default_version' => '5.5',
              '5.5' => 'mysql-server-5.5'
            },
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
            'default_data_dir' => '/opt/local/lib/mysql',
            # Do this or now, until Ohai correctly detects a
            # smartmachine vs global zone (base64 13.4.0) from /etc/product
            '5.11' => {
              'default_version' => '5.5',
              '5.5' => 'mysql-server',
              '5.6' => 'mysql-server'
            }
          },
          'omnios' => {
            'default_data_dir' => '/var/lib/mysql',
            '151006' => {
              'default_version' => '5.5',
              '5.5' => 'database/mysql-55',
              '5.6' => 'database/mysql-56'
            }
          }
        }
      end
    end
  end
end
