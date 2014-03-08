# comments go here

use_inline_resources

def whyrun_supported?
  true
end

action :create do

  template '/tmp/mysql-init.txt' do
    source 'mysql-init.txt.erb'
    cookbook 'mysql'
    variables(:password => new_resource.password)
    notifies :run, 'execute[set mysql root password]'
    not_if "mysql -u 'root' -h 'localhost' -p#{new_resource.password} -e 'show databases;'"
  end

  script 'force mysql root password' do
    code <<-EOH
    '/usr/libexec/mysqld --init-file /tmp/mysql-init.txt & ;
    rm /tmp/mysql-init.txt' ;
    EOH
    action :nothing
  end

end
