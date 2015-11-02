name 'mysql'
maintainer 'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license 'Apache 2.0'
description 'Provides mysql_service, mysql_config, and mysql_client resources'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '6.1.2'

supports 'amazon'
supports 'redhat'
supports 'centos'
supports 'scientific'
supports 'fedora'
supports 'debian'
supports 'ubuntu'
supports 'smartos'
supports 'omnios'
supports 'suse'

depends 'yum-mysql-community'
depends 'smf'

source_url 'https://github.com/chef-cookbooks/mysql' if respond_to?(:source_url)
issues_url 'https://github.com/chef-cookbooks/mysql/issues' if respond_to?(:issues_url)
