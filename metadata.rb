name              'mysql'
maintainer        'Sous Chefs'
maintainer_email  'help@sous-chefs.org'
license           'Apache-2.0'
description       'Provides mysql_service, mysql_config, and mysql_client resources'
source_url        'https://github.com/sous-chefs/mysql'
issues_url        'https://github.com/sous-chefs/mysql/issues'
chef_version      '>= 15.5'
version           '11.0.1'

depends 'apparmor'

%w(redhat centos scientific oracle).each do |el|
  supports el, '>= 7.0'
end

supports 'amazon'
supports 'fedora'
supports 'debian', '>= 9.0'
supports 'ubuntu', '>= 18.04'
supports 'opensuseleap'
supports 'suse', '>= 12.0'
