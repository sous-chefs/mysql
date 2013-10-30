emacase node['platform_family']

when 'windows'
  default['mysql']['server']['packages']      = ['MySQL Server 5.5']
  default['mysql']['version']                 = '5.5.32'
  default['mysql']['arch']                    = 'win32'
  default['mysql']['package_file']            = "mysql-#{mysql['version']}-#{mysql['arch']}.msi"
  default['mysql']['url']                     = "http://www.mysql.com/get/Downloads/MySQL-5.5/#{mysql['package_file']}/from/http://mysql.mirrors.pair.com/"

  default['mysql']['service_name']            = 'mysql'
  default['mysql']['basedir']                 = "#{ENV['SYSTEMDRIVE']}\\Program Files (x86)\\MySQL\\#{mysql['server']['packages'].first}"
  default['mysql']['data_dir']                = "#{node['mysql']['basedir']}\\Data"
  default['mysql']['bin_dir']                 = "#{node['mysql']['basedir']}\\bin"
  default['mysql']['mysqladmin_bin']          = "#{node['mysql']['bin_dir']}\\mysqladmin"
  default['mysql']['mysql_bin']               = "#{node['mysql']['bin_dir']}\\mysql"

  default['mysql']['conf_dir']                = node['mysql']['basedir']
  default['mysql']['old_passwords']           = 0
  default['mysql']['grants_path']             = "#{node['mysql']['conf_dir']}\\grants.sql"
end
