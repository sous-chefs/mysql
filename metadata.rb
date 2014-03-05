name		          'rackspace_mysql'
maintainer        'Rackspace, US Inc.'
maintainer_email  'rackspace-cookbooks@rackspace.com'
license           'Apache 2.0'
description       'Installs and configures mysql for client or server'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '6.0.0'

recipe            'rackspace_mysql', 'Includes the client recipe to configure a client'
recipe            'rackspace_mysql::client', 'Installs packages required for mysql clients using run_action magic'
recipe            'rackspace_mysql::server', 'Installs packages required for mysql servers w/o manual intervention'

# actually tested on
supports 'redhat'
supports 'centos'
supports 'debian'
supports 'ubuntu'

depends 'openssl',         '~> 1.1'
depends 'rackspace_build_essential', '~> 2.0'
depends 'rackspace_apt',   '~> 3.0'
depends 'rackspace_yum',   '~> 4.0'
