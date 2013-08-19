default['mysql']['mariadb']['apt_key_id'] = '0xcbcb082a1bb943db'
default['mysql']['mariadb']['apt_uri'] = "http://ftp.osuosl.org/pub/mariadb/repo/10.0/#{node['platform']}"
default['mysql']['mariadb']['apt_keyserver'] = "keyserver.ubuntu.com"

arch = case node['kernel']['machine']
       when "x86_64" then "amd64"
       when "amd64" then "amd64"
       else "x86"
       end
pversion = node['platform_version'].split('.').first
default['mysql']['mariadb']['yum_uri'] = "http://yum.mariadb.org/10.0/#{node['platform']}#{pversion}-#{arch}"
