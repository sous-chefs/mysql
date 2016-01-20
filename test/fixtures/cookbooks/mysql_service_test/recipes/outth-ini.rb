template '/tmp/outth-mysql-instance_1.ini' do
    source 'outth-mysql.ini.erb'
    variables({ 
        :port => 3307,
        :user => 'root',
        :password => 'ilikerandompasswords'
    }) 
end
