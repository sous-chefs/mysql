# frozen_string_literal: true

name              'mysql'
maintainer        'Sous Chefs'
maintainer_email  'help@sous-chefs.org'
license           'Apache-2.0'
description       'Provides mysql_service, mysql_config, and mysql_client resources'
source_url        'https://github.com/sous-chefs/mysql'
issues_url        'https://github.com/sous-chefs/mysql/issues'
chef_version      '>= 15.3'
version           '11.1.11'

depends 'apparmor'

supports 'almalinux', '>= 8.0'
supports 'amazon', '>= 2023.0'
supports 'centos_stream', '>= 9.0'
supports 'debian', '>= 12.0'
supports 'fedora'
supports 'opensuseleap', '>= 15.0'
supports 'oracle', '>= 8.0'
supports 'redhat', '>= 8.0'
supports 'rocky', '>= 8.0'
supports 'ubuntu', '>= 20.04'
